/**
 * Smart Inventory — ESP32 RFID + BLE Scanner
 *
 * Hardware:
 *   - ESP32 (any variant with SPI + built-in BLE)
 *   - MFRC522 RFID reader wired:
 *       MOSI → GPIO 23  |  MISO → GPIO 19
 *       SCK  → GPIO 18  |  SS   → GPIO 21
 *       RST  → GPIO 22  |  3.3V / GND
 *
 * Libraries required (Arduino Library Manager):
 *   - MFRC522 by GithubCommunity
 *   - PubSubClient by Nick O'Leary
 *   - ArduinoJson by Benoit Blanchon
 *   - ESP32 BLE Arduino (bundled with esp32 board package)
 *
 * Dynamic config — backend can update BLE MAC list at any time by publishing
 * to:  inventory/devices/{READER_ID}/config
 * Payload example:
 *   { "ble_macs": ["aa:bb:cc:dd:ee:ff", "11:22:33:44:55:66"] }
 * No re-flash needed.
 */

#include <WiFi.h>
#include <PubSubClient.h>
#include <SPI.h>
#include <MFRC522.h>
#include <BLEDevice.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <ArduinoJson.h>
#include <vector>

// ════════════════════════════════════════════════════════════════════════════
//  USER CONFIGURATION  — edit this section before flashing
// ════════════════════════════════════════════════════════════════════════════

#define WIFI_SSID       "iPhone"
#define WIFI_PASSWORD   "12345678"

#define MQTT_BROKER     "172.20.10.6"
#define MQTT_PORT       1883

#define READER_ID       "esp32_labo_iot1"
#define ROOM_ID         "e88f0c40-f527-4e8c-9bb8-9819c02a70b8"

// Match Apple Find My accessories by manufacturer data prefix (MAC rotates on Apple)
#define BLE_MATCH_BY_ADV_PREFIX true
const uint8_t BLE_ADV_PREFIX[]  = { 0x4C, 0x00, 0x12 };  // Apple company ID + FindMy type (matches both short 0x02 and long 0x19 ads)
#define       BLE_ADV_PREFIX_LEN  3

// ════════════════════════════════════════════════════════════════════════════
//  PIN DEFINITIONS
// ════════════════════════════════════════════════════════════════════════════

#define RST_PIN   22
#define SS_PIN    21
#define MOSI_PIN  23
#define MISO_PIN  19
#define SCK_PIN   18

// ════════════════════════════════════════════════════════════════════════════
//  MQTT TOPICS
// ════════════════════════════════════════════════════════════════════════════

#define TOPIC_RFID    "inventory/rfid"
#define TOPIC_BLE     "inventory/ble"
#define TOPIC_STATUS  "inventory/devices/" READER_ID "/status"
#define TOPIC_CONFIG  "inventory/devices/" READER_ID "/config"

// ════════════════════════════════════════════════════════════════════════════
//  TIMING
// ════════════════════════════════════════════════════════════════════════════

#define BLE_SCAN_SECONDS   5
#define BLE_SCAN_INTERVAL  15000UL
#define RFID_DEBOUNCE_MS   1500UL

// ════════════════════════════════════════════════════════════════════════════
//  DYNAMIC BLE MAC LIST  — updated at runtime via MQTT config message
//  No need to re-flash to add or remove BLE devices.
// ════════════════════════════════════════════════════════════════════════════

std::vector<String> knownBleMacs;  // populated from MQTT config at runtime

void addBleMac(const String& mac) {
  String m = mac;
  m.toLowerCase();
  for (const String& existing : knownBleMacs) {
    if (existing == m) return; // already in list
  }
  knownBleMacs.push_back(m);
  Serial.printf("BLE MAC added: %s  (total: %d)\n", m.c_str(), (int)knownBleMacs.size());
}

void clearBleMacs() {
  knownBleMacs.clear();
  Serial.println("BLE MAC list cleared.");
}

bool isKnownBleMac(const String& mac) {
  String m = mac;
  m.toLowerCase();
  for (const String& known : knownBleMacs) {
    if (known == m) return true;
  }
  return false;
}

// ════════════════════════════════════════════════════════════════════════════
//  GLOBALS
// ════════════════════════════════════════════════════════════════════════════

WiFiClient   espClient;
PubSubClient mqtt(espClient);
MFRC522      rfid(SS_PIN, RST_PIN);
BLEScan*     bleScan = nullptr;

unsigned long lastBleScanTime = 0;
String        lastRfidUid     = "";
unsigned long lastRfidTime    = 0;

// ════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════════════════════════════

String uidToString(MFRC522::Uid& uid) {
  String s = "";
  for (byte i = 0; i < uid.size; i++) {
    if (i > 0) s += ":";
    if (uid.uidByte[i] < 0x10) s += "0";
    s += String(uid.uidByte[i], HEX);
  }
  s.toUpperCase();
  return s;
}

bool matchesByAdvPrefix(BLEAdvertisedDevice& dev) {
  if (!dev.haveManufacturerData()) return false;
  String mfr = dev.getManufacturerData();
  if ((size_t)mfr.length() < BLE_ADV_PREFIX_LEN) return false;
  for (int i = 0; i < BLE_ADV_PREFIX_LEN; i++) {
    if ((uint8_t)mfr[i] != BLE_ADV_PREFIX[i]) return false;
  }
  return true;
}

String bytesToHex(const String& raw, int maxBytes = 12) {
  String out = "";
  int len = min((int)raw.length(), maxBytes);
  for (int i = 0; i < len; i++) {
    uint8_t b = (uint8_t)raw[i];
    if (b < 0x10) out += "0";
    out += String(b, HEX);
  }
  out.toUpperCase();
  return out;
}

void publishJson(const char* topic, JsonDocument& doc, bool retain = false) {
  char buf[512];
  serializeJson(doc, buf);
  if (!mqtt.publish(topic, buf, retain)) {
    Serial.println("  WARNING: publish failed");
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  MQTT CONFIG HANDLER
//  Backend publishes to TOPIC_CONFIG to update BLE MAC list dynamically.
//
//  Supported payloads:
//
//  1. Replace full list:
//     { "ble_macs": ["aa:bb:cc:dd:ee:ff", "11:22:33:44:55:66"] }
//
//  2. Add single MAC:
//     { "add_mac": "aa:bb:cc:dd:ee:ff" }
//
//  3. Clear all MACs:
//     { "clear_macs": true }
// ════════════════════════════════════════════════════════════════════════════

void handleConfigMessage(const String& payload) {
  StaticJsonDocument<512> doc;
  DeserializationError err = deserializeJson(doc, payload);
  if (err) {
    Serial.printf("Config parse error: %s\n", err.c_str());
    return;
  }

  // Replace full BLE MAC list
  if (doc.containsKey("ble_macs") && doc["ble_macs"].is<JsonArray>()) {
    clearBleMacs();
    JsonArray arr = doc["ble_macs"].as<JsonArray>();
    for (JsonVariant v : arr) {
      addBleMac(String(v.as<const char*>()));
    }
    Serial.printf("BLE MAC list updated — %d MACs loaded.\n", (int)knownBleMacs.size());
  }

  // Add a single MAC
  if (doc.containsKey("add_mac")) {
    addBleMac(String(doc["add_mac"].as<const char*>()));
  }

  // Clear all MACs
  if (doc.containsKey("clear_macs") && doc["clear_macs"].as<bool>()) {
    clearBleMacs();
  }

  // Acknowledge back to backend
  StaticJsonDocument<128> ack;
  ack["reader_id"]    = READER_ID;
  ack["ble_mac_count"] = (int)knownBleMacs.size();
  ack["status"]       = "config_applied";
  publishJson(TOPIC_STATUS, ack, false);
}

// ════════════════════════════════════════════════════════════════════════════
//  MQTT INCOMING MESSAGE HANDLER
// ════════════════════════════════════════════════════════════════════════════

void mqttOnMessage(char* topic, byte* payload, unsigned int len) {
  String msg;
  for (unsigned int i = 0; i < len; i++) msg += (char)payload[i];
  Serial.printf("MQTT <- [%s] %s\n", topic, msg.c_str());

  if (String(topic) == TOPIC_CONFIG) {
    handleConfigMessage(msg);
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  BLE SCAN CALLBACK
// ════════════════════════════════════════════════════════════════════════════

class InventoryBleCallbacks : public BLEAdvertisedDeviceCallbacks {
  void onResult(BLEAdvertisedDevice dev) override {
    String mac = dev.getAddress().toString().c_str();

    if (dev.haveManufacturerData()) {
      String mfr = dev.getManufacturerData();
      String hex = "";
      for (int i = 0; i < min((int)mfr.length(), 6); i++) {
        if (i > 0) hex += " ";
        uint8_t b = (uint8_t)mfr[i];
        if (b < 0x10) hex += "0";
        hex += String(b, HEX);
      }
      Serial.printf("BLE: %s  mfr[0:6]=%s  RSSI=%d\n",
                    mac.c_str(), hex.c_str(), dev.getRSSI());
    }

    // Match by Apple Find My prefix OR by known MAC list (dynamic)
    bool hit = BLE_MATCH_BY_ADV_PREFIX
                 ? matchesByAdvPrefix(dev)
                 : isKnownBleMac(mac);
    if (!hit) return;

    int rssi = dev.getRSSI();

    // Use manufacturer payload as stable fingerprint for Apple Find My
    // because MAC address rotates every 15 minutes on Apple devices
    String fingerprint = mac;
    if (BLE_MATCH_BY_ADV_PREFIX && dev.haveManufacturerData()) {
      fingerprint = "FINDMY:" + bytesToHex(dev.getManufacturerData(), 14);
    }

    Serial.printf("BLE match: %s  RSSI=%d\n", fingerprint.c_str(), rssi);

    StaticJsonDocument<384> doc;
    doc["mac"]         = mac;
    doc["fingerprint"] = fingerprint;
    doc["rssi"]        = rssi;
    doc["room_id"]     = ROOM_ID;
    doc["reader_id"]   = READER_ID;
    publishJson(TOPIC_BLE, doc, false);
  }
};

// ════════════════════════════════════════════════════════════════════════════
//  WIFI
// ════════════════════════════════════════════════════════════════════════════

void setupWifi() {
  Serial.printf("WiFi: connecting to %s", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.printf("\nWiFi OK — IP: %s\n", WiFi.localIP().toString().c_str());
}

// ════════════════════════════════════════════════════════════════════════════
//  MQTT
// ════════════════════════════════════════════════════════════════════════════

void connectMqtt() {
  while (!mqtt.connected()) {
    Serial.print("MQTT connecting... ");
    String cid = "inv_" + String(READER_ID) + "_" + String(random(0xFFFF), HEX);
    bool ok = mqtt.connect(
      cid.c_str(),
      nullptr, nullptr,
      TOPIC_STATUS, 0, true,
      "{\"status\":\"offline\",\"reader_id\":\"" READER_ID "\"}"
    );

    if (ok) {
      Serial.println("OK");
      mqtt.subscribe(TOPIC_CONFIG); // subscribe to receive dynamic config updates

      StaticJsonDocument<128> doc;
      doc["status"]       = "online";
      doc["reader_id"]    = READER_ID;
      doc["room_id"]      = ROOM_ID;
      doc["ble_mac_count"] = (int)knownBleMacs.size();
      publishJson(TOPIC_STATUS, doc, true);

      Serial.println("Subscribed to config topic — waiting for BLE MAC list from backend.");
    } else {
      Serial.printf("failed rc=%d — retry in 5s\n", mqtt.state());
      delay(5000);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SETUP
// ════════════════════════════════════════════════════════════════════════════

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== Smart Inventory RFID+BLE Reader ===");
  Serial.printf("Reader : %s\n", READER_ID);
  Serial.printf("Room   : %s\n", ROOM_ID);
  Serial.println("BLE MAC list: empty — will be loaded from backend via MQTT config.");

  // RFID
  SPI.begin(SCK_PIN, MISO_PIN, MOSI_PIN, SS_PIN);
  rfid.PCD_Init();
  rfid.PCD_DumpVersionToSerial();

  // WiFi + MQTT
  setupWifi();
  mqtt.setServer(MQTT_BROKER, MQTT_PORT);
  mqtt.setCallback(mqttOnMessage);
  mqtt.setBufferSize(512);
  connectMqtt();

  // BLE
  BLEDevice::init("");
  bleScan = BLEDevice::getScan();
  bleScan->setAdvertisedDeviceCallbacks(new InventoryBleCallbacks(), false);
  bleScan->setActiveScan(true);
  bleScan->setInterval(100);
  bleScan->setWindow(99);

  Serial.println("Ready.\n");
}

// ════════════════════════════════════════════════════════════════════════════
//  LOOP
// ════════════════════════════════════════════════════════════════════════════

void loop() {
  if (!mqtt.connected()) connectMqtt();
  mqtt.loop();

  // ── RFID ─────────────────────────────────────────────────────────────────
  // Publishes EVERY scanned tag — backend resolves which product it belongs to.
  // No hardcoded list needed here: the database is the source of truth.
  if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
    String uid = uidToString(rfid.uid);
    unsigned long now = millis();

    bool sameTag = (uid == lastRfidUid);
    bool tooSoon = (now - lastRfidTime < RFID_DEBOUNCE_MS);

    if (!(sameTag && tooSoon)) {
      Serial.printf("RFID: %s\n", uid.c_str());

      StaticJsonDocument<256> doc;
      doc["uid"]       = uid;
      doc["room_id"]   = ROOM_ID;
      doc["reader_id"] = READER_ID;
      publishJson(TOPIC_RFID, doc, false);
      Serial.println("  published");

      lastRfidUid  = uid;
      lastRfidTime = now;
    }

    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();
  }

  // ── BLE periodic scan ────────────────────────────────────────────────────
  unsigned long now = millis();
  if (now - lastBleScanTime >= BLE_SCAN_INTERVAL) {
    lastBleScanTime = now;
    Serial.printf("BLE scan...  (%d MACs in list)\n", (int)knownBleMacs.size());
    bleScan->clearResults();
    bleScan->start(BLE_SCAN_SECONDS, false);
  }

  delay(10);
}
