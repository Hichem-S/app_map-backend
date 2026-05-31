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
 */

#include <WiFi.h>
#include <PubSubClient.h>
#include <SPI.h>
#include <MFRC522.h>
#include <BLEDevice.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <ArduinoJson.h>

// ════════════════════════════════════════════════════════════════════════════
//  USER CONFIGURATION  — edit this section before flashing
// ════════════════════════════════════════════════════════════════════════════

#define WIFI_SSID       "iPhone"
#define WIFI_PASSWORD   "12345678"

#define MQTT_BROKER     "192.168.31.23"
#define MQTT_PORT       1883

#define READER_ID       "esp32_labo_iot1"
#define ROOM_ID         "e88f0c40-f527-4e8c-9bb8-9819c02a70b8"  // Labo IoT 1

// ────────────────────────────────────────────────────────────────────────────
//  KNOWN RFID TAG UIDs  (uppercase, colon-separated)
// ────────────────────────────────────────────────────────────────────────────
const char* KNOWN_RFID_TAGS[] = {
  "49:A2:1C:06",
  "B4:18:FA:05",
  "44:7E:D1:E9",
  "44:DE:DB:E9",
};

// ────────────────────────────────────────────────────────────────────────────
//  KNOWN BLE MAC ADDRESSES  (lowercase, colon-separated)
// ────────────────────────────────────────────────────────────────────────────
const char* KNOWN_BLE_MACS[] = {
  "aa:bb:cc:dd:ee:ff",
  // add more MACs here
};

// Match Apple Find My accessories by manufacturer data prefix (not MAC — MAC rotates)
#define BLE_MATCH_BY_ADV_PREFIX true
const uint8_t BLE_ADV_PREFIX[]  = { 0x4C, 0x00, 0x12, 0x19 };  // Apple + Find My + OpenHaystack subtype
#define       BLE_ADV_PREFIX_LEN  4

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
//  GLOBALS
// ════════════════════════════════════════════════════════════════════════════

WiFiClient   espClient;
PubSubClient mqtt(espClient);
MFRC522      rfid(SS_PIN, RST_PIN);
BLEScan*     bleScan = nullptr;

unsigned long lastBleScanTime = 0;
String        lastRfidUid     = "";
unsigned long lastRfidTime    = 0;

const int KNOWN_RFID_COUNT = sizeof(KNOWN_RFID_TAGS) / sizeof(KNOWN_RFID_TAGS[0]);
const int KNOWN_BLE_COUNT  = sizeof(KNOWN_BLE_MACS)  / sizeof(KNOWN_BLE_MACS[0]);

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

bool isKnownRfid(const String& uid) {
  for (int i = 0; i < KNOWN_RFID_COUNT; i++) {
    if (uid.equalsIgnoreCase(KNOWN_RFID_TAGS[i])) return true;
  }
  return false;
}

bool isKnownBleMac(const String& mac) {
  for (int i = 0; i < KNOWN_BLE_COUNT; i++) {
    if (mac.equalsIgnoreCase(KNOWN_BLE_MACS[i])) return true;
  }
  return false;
}

bool matchesByAdvPrefix(BLEAdvertisedDevice& dev) {
  if (!dev.haveManufacturerData()) return false;
  String mfr = dev.getManufacturerData();           // Arduino String, not std::string
  if ((size_t)mfr.length() < BLE_ADV_PREFIX_LEN) return false;
  for (int i = 0; i < BLE_ADV_PREFIX_LEN; i++) {
    if ((uint8_t)mfr[i] != BLE_ADV_PREFIX[i]) return false;
  }
  return true;
}

void publishJson(const char* topic, JsonDocument& doc, bool retain = false) {
  char buf[384];
  serializeJson(doc, buf);
  if (!mqtt.publish(topic, buf, retain)) {
    Serial.println("  WARNING: publish failed");
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  BLE SCAN CALLBACK
// ════════════════════════════════════════════════════════════════════════════

// Convert raw bytes to uppercase hex string (e.g. "4C001219AB...")
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

class InventoryBleCallbacks : public BLEAdvertisedDeviceCallbacks {
  void onResult(BLEAdvertisedDevice dev) override {
    String mac = dev.getAddress().toString().c_str();

    // Debug: print every device with manufacturer data
    if (dev.haveManufacturerData()) {
      String mfr = dev.getManufacturerData();
      String hex = "";
      for (int i = 0; i < min((int)mfr.length(), 6); i++) {
        if (i > 0) hex += " ";
        uint8_t b = (uint8_t)mfr[i];
        if (b < 0x10) hex += "0";
        hex += String(b, HEX);
      }
      Serial.printf("BLE device: %s  mfr[0:6]=%s  RSSI=%d\n",
                    mac.c_str(), hex.c_str(), dev.getRSSI());
    }

    bool   hit = BLE_MATCH_BY_ADV_PREFIX ? matchesByAdvPrefix(dev)
                                         : isKnownBleMac(mac);
    if (!hit) return;

    int rssi = dev.getRSSI();

    // For Apple Find My: MAC rotates, use manufacturer payload as stable fingerprint
    // Payload bytes after the Apple prefix identify the specific device
    String fingerprint = mac;  // fallback to MAC for non-Apple BLE
    if (BLE_MATCH_BY_ADV_PREFIX && dev.haveManufacturerData()) {
      fingerprint = "FINDMY:" + bytesToHex(dev.getManufacturerData(), 14);
    }

    Serial.printf("BLE Apple FindMy: %s  RSSI=%d\n", fingerprint.c_str(), rssi);

    StaticJsonDocument<384> doc;
    doc["mac"]         = mac;          // still sent (may rotate, for info only)
    doc["fingerprint"] = fingerprint;  // stable identifier for backend matching
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

void mqttOnMessage(char* topic, byte* payload, unsigned int len) {
  String msg;
  for (unsigned int i = 0; i < len; i++) msg += (char)payload[i];
  Serial.printf("MQTT <- [%s] %s\n", topic, msg.c_str());
}

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
      mqtt.subscribe(TOPIC_CONFIG);

      StaticJsonDocument<96> doc;
      doc["status"]    = "online";
      doc["reader_id"] = READER_ID;
      doc["room_id"]   = ROOM_ID;
      publishJson(TOPIC_STATUS, doc, true);
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
  Serial.printf("Tags   : %d known RFID  |  %d known BLE\n",
                KNOWN_RFID_COUNT, KNOWN_BLE_COUNT);

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

  // ── RFID ────────────────────────────────────────────────────────────────
  if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
    String uid = uidToString(rfid.uid);
    unsigned long now = millis();

    bool sameTag = (uid == lastRfidUid);
    bool tooSoon = (now - lastRfidTime < RFID_DEBOUNCE_MS);

    if (!(sameTag && tooSoon)) {
      Serial.printf("RFID: %s\n", uid.c_str());

      // Publish every tag — backend resolves product and handles zoning
      StaticJsonDocument<256> doc;
      doc["uid"]       = uid;
      doc["room_id"]   = ROOM_ID;
      doc["reader_id"] = READER_ID;
      publishJson(TOPIC_RFID, doc, false);
      Serial.println("  → published");

      lastRfidUid  = uid;
      lastRfidTime = now;
    }

    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();
  }

  // ── BLE periodic scan ───────────────────────────────────────────────────
  unsigned long now = millis();
  if (now - lastBleScanTime >= BLE_SCAN_INTERVAL) {
    lastBleScanTime = now;
    Serial.println("BLE scan...");
    bleScan->clearResults();
    bleScan->start(BLE_SCAN_SECONDS, false);
  }

  delay(10);
}
