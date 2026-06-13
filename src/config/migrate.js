const { query } = require("./database");
require("dotenv").config();

const migrate = async () => {
  try {
    // Users table
    await query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(100) NOT NULL,
        email VARCHAR(150) UNIQUE NOT NULL,
        password VARCHAR(255),
        role VARCHAR(20) DEFAULT 'user',
        avatar VARCHAR(255),
        phone VARCHAR(30),
        google_id VARCHAR(100) UNIQUE,
        email_verified BOOLEAN DEFAULT false,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);

    // Add new columns to users if upgrading from old schema
    await query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(30);`);
    await query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(100) UNIQUE;`);
    await query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT false;`);
    await query(`ALTER TABLE users ALTER COLUMN password DROP NOT NULL;`).catch(() => {});

    // Refresh tokens table
    await query(`
      CREATE TABLE IF NOT EXISTS refresh_tokens (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        token VARCHAR(64) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens(user_id);`);

    // Categories table (supports nesting)
    await query(`
      CREATE TABLE IF NOT EXISTS categories (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR(100) NOT NULL,
        parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`CREATE UNIQUE INDEX IF NOT EXISTS idx_categories_name ON categories(name);`);

    // Seed default categories for ISET Mahdia
    await query(`
      INSERT INTO categories (name) VALUES
        ('Computer'),
        ('Server'),
        ('Network Device'),
        ('Peripheral'),
        ('Printer/Scanner'),
        ('Display'),
        ('Projector'),
        ('Machine Tool')
      ON CONFLICT (name) DO NOTHING;
    `);

    // Products table
    await query(`
      CREATE TABLE IF NOT EXISTS products (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE SET NULL,
        category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
        name VARCHAR(200) NOT NULL,
        sku VARCHAR(100) UNIQUE NOT NULL,
        barcode VARCHAR(100),
        description TEXT,
        tags TEXT[],
        quantity INTEGER DEFAULT 0,
        price DECIMAL(12,2),
        storage_location VARCHAR(200),
        photo_url VARCHAR(500),
        qr_data TEXT,
        status VARCHAR(30) DEFAULT 'in_stock',
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_user ON products(user_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS qr_image_url VARCHAR(500);`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS specifications JSONB;`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS department VARCHAR(10);`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS classroom VARCHAR(150);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_department ON products(department);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_classroom ON products(classroom);`);

    // ── Departments ──────────────────────────────────────────────────────────────
    await query(`
      CREATE TABLE IF NOT EXISTS departments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        code VARCHAR(10) UNIQUE NOT NULL,
        name VARCHAR(100) NOT NULL,
        color VARCHAR(20) DEFAULT '#6366F1',
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`
      INSERT INTO departments (code, name, color) VALUES
        ('I',   'Informatique',           '#3B5BDB'),
        ('M',   'Mécanique',              '#F97316'),
        ('G',   'Gestion',                '#16A34A'),
        ('E',   'Électrique',             '#F59E0B'),
        ('TC',  'Commerce Techniques',    '#00BFA5'),
        ('ADM', 'Administration Générale','#7B1FA2')
      ON CONFLICT (code) DO NOTHING;
    `);

    // ── Rooms ────────────────────────────────────────────────────────────────────
    await query(`
      CREATE TABLE IF NOT EXISTS rooms (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        department_id UUID REFERENCES departments(id) ON DELETE CASCADE,
        name VARCHAR(150) NOT NULL,
        type VARCHAR(20) DEFAULT 'classroom',
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE (department_id, name)
      );
    `);

    await query(`CREATE INDEX IF NOT EXISTS idx_rooms_department ON rooms(department_id);`);

    // Seed rooms for each department
    await query(`
      INSERT INTO rooms (department_id, name, type)
      SELECT d.id, r.name, r.type
      FROM departments d
      JOIN (VALUES
        ('I', 'Salle I1', 'classroom'), ('I', 'Salle I2', 'classroom'),
        ('I', 'Salle I3', 'classroom'), ('I', 'Salle I4', 'classroom'),
        ('I', 'Salle I5', 'classroom'),
        ('M', 'Salle M1', 'classroom'), ('M', 'Salle M2', 'classroom'),
        ('M', 'Salle M3', 'classroom'), ('M', 'Salle M4', 'classroom'),
        ('M', 'Salle M5', 'classroom'),
        ('G', 'Salle G1', 'classroom'), ('G', 'Salle G2', 'classroom'),
        ('G', 'Salle G3', 'classroom'), ('G', 'Salle G4', 'classroom'),
        ('G', 'Salle G5', 'classroom'),
        ('E',   'Salle E1',   'classroom'), ('E',   'Salle E2',   'classroom'),
        ('E',   'Salle E3',   'classroom'), ('E',   'Salle E4',   'classroom'),
        ('E',   'Salle E5',   'classroom'),
        ('TC',  'Salle TC1',  'classroom'), ('TC',  'Salle TC2',  'classroom'),
        ('TC',  'Salle TC3',  'classroom'), ('TC',  'Salle TC4',  'classroom'),
        ('TC',  'Salle TC5',  'classroom'),
        ('ADM', 'Salle ADM1', 'office'),    ('ADM', 'Salle ADM2', 'office')
      ) AS r(code, name, type) ON d.code = r.code
      ON CONFLICT (department_id, name) DO NOTHING;
    `);

    // Extra room metadata columns
    await query(`ALTER TABLE rooms ADD COLUMN IF NOT EXISTS room_code VARCHAR(20);`);
    await query(`ALTER TABLE rooms ADD COLUMN IF NOT EXISTS bloc VARCHAR(50);`);
    await query(`ALTER TABLE rooms ADD COLUMN IF NOT EXISTS floor VARCHAR(50);`);
    await query(`ALTER TABLE rooms ADD COLUMN IF NOT EXISTS capacity INTEGER DEFAULT 30;`);

    // Add room_id FK to products
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS room_id UUID REFERENCES rooms(id) ON DELETE SET NULL;`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_room ON products(room_id);`);

    // Track who last moved each product to a new location
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS last_moved_by UUID REFERENCES users(id) ON DELETE SET NULL;`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS last_moved_at TIMESTAMP;`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_last_moved_by ON products(last_moved_by);`);

    // Devices table (IoT / MQTT trackers)
    await query(`
      CREATE TABLE IF NOT EXISTS devices (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(100) NOT NULL,
        device_type VARCHAR(50),
        mqtt_topic VARCHAR(200),
        status VARCHAR(20) DEFAULT 'offline',
        last_seen TIMESTAMP,
        metadata JSONB,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);

    // MQTT messages table
    await query(`
      CREATE TABLE IF NOT EXISTS messages (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE SET NULL,
        device_id UUID REFERENCES devices(id) ON DELETE SET NULL,
        topic VARCHAR(200),
        payload JSONB,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`CREATE INDEX IF NOT EXISTS idx_messages_topic ON messages(topic);`);

    // Scan history table
    await query(`
      CREATE TABLE IF NOT EXISTS scan_history (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        product_id UUID REFERENCES products(id) ON DELETE CASCADE,
        scanned_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`CREATE INDEX IF NOT EXISTS idx_scan_history_user ON scan_history(user_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_scan_history_product ON scan_history(product_id);`);

    // Department QR history columns (idempotent)
    await query(`ALTER TABLE scan_history ADD COLUMN IF NOT EXISTS department_code TEXT;`);
    await query(`ALTER TABLE scan_history ADD COLUMN IF NOT EXISTS department_name TEXT;`);

    // Action type: 'scan' | 'product_added' | 'dept_qr' | 'moved' | 'status_changed'
    await query(`ALTER TABLE scan_history ADD COLUMN IF NOT EXISTS action_type TEXT NOT NULL DEFAULT 'scan';`);
    // Extra context JSON: {"to_room":"Salle I2"} or {"new_status":"in_maintenance","old_status":"in_stock"}
    await query(`ALTER TABLE scan_history ADD COLUMN IF NOT EXISTS action_data TEXT;`);

    // Email verification tokens
    await query(`
      CREATE TABLE IF NOT EXISTS email_verification_tokens (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        token_hash VARCHAR(64) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_evt_user  ON email_verification_tokens(user_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_evt_token ON email_verification_tokens(token_hash);`);

    // Password reset tokens
    await query(`
      CREATE TABLE IF NOT EXISTS password_reset_tokens (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        token_hash VARCHAR(64) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        used BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_prt_user ON password_reset_tokens(user_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_prt_token ON password_reset_tokens(token_hash);`);

    // Notifications table
    await query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        type VARCHAR(50) NOT NULL DEFAULT 'product_moved',
        title VARCHAR(255),
        body TEXT,
        product_id UUID REFERENCES products(id) ON DELETE SET NULL,
        product_name VARCHAR(255),
        from_room VARCHAR(255),
        to_room VARCHAR(255),
        is_read BOOLEAN NOT NULL DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read);`);

    // ── AirTag-style tracker columns on products ──────────────────────────────
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS tracker_active BOOLEAN DEFAULT false;`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS tracker_lat DECIMAL(10,7);`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS tracker_lng DECIMAL(10,7);`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS tracker_battery INTEGER;`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS tracker_checked_at TIMESTAMP;`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_tracker ON products(tracker_active) WHERE tracker_active = true;`);

    // ── AirTag FindMy key link ────────────────────────────────────────────────
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS tracker_hashed_key TEXT;`);
    await query(`CREATE UNIQUE INDEX IF NOT EXISTS idx_products_tracker_key ON products(tracker_hashed_key) WHERE tracker_hashed_key IS NOT NULL;`);

    // ── BLE device linking ────────────────────────────────────────────────────
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS ble_device VARCHAR(50);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_ble ON products(ble_device) WHERE ble_device IS NOT NULL;`);

    // RFID tag column + index
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS rfid_tag VARCHAR(100);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_rfid ON products(rfid_tag) WHERE rfid_tag IS NOT NULL;`);

    // Unregistered RFID/BLE scans — tags not yet linked to any product
    await query(`
      CREATE TABLE IF NOT EXISTS unregistered_scans (
        id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        uid         TEXT NOT NULL,
        scan_type   TEXT NOT NULL DEFAULT 'rfid',
        room_id     UUID REFERENCES rooms(id) ON DELETE SET NULL,
        room_name   TEXT,
        reader_id   TEXT,
        scanned_at  TIMESTAMP DEFAULT NOW(),
        resolved    BOOLEAN DEFAULT FALSE,
        resolved_by UUID REFERENCES users(id) ON DELETE SET NULL,
        resolved_at TIMESTAMP,
        product_id  UUID REFERENCES products(id) ON DELETE SET NULL
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_unreg_uid      ON unregistered_scans(uid);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_unreg_resolved ON unregistered_scans(resolved);`);

    // ── Messenger ─────────────────────────────────────────────────────────────
    await query(`ALTER TABLE users ADD COLUMN IF NOT EXISTS last_seen TIMESTAMP;`);

    await query(`
      CREATE TABLE IF NOT EXISTS chat_conversations (
        id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        type       VARCHAR(10) NOT NULL DEFAULT 'direct',
        name       VARCHAR(100),
        created_by UUID REFERENCES users(id) ON DELETE SET NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`
      CREATE TABLE IF NOT EXISTS chat_members (
        conversation_id UUID REFERENCES chat_conversations(id) ON DELETE CASCADE,
        user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
        last_read_at    TIMESTAMP DEFAULT NOW(),
        joined_at       TIMESTAMP DEFAULT NOW(),
        PRIMARY KEY (conversation_id, user_id)
      );
    `);

    await query(`
      CREATE TABLE IF NOT EXISTS chat_messages (
        id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        conversation_id UUID REFERENCES chat_conversations(id) ON DELETE CASCADE,
        sender_id       UUID REFERENCES users(id) ON DELETE SET NULL,
        content         TEXT NOT NULL,
        created_at      TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`CREATE INDEX IF NOT EXISTS idx_chat_msgs_conv ON chat_messages(conversation_id, created_at DESC);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_chat_members_user ON chat_members(user_id);`);

    // ── Checkouts ─────────────────────────────────────────────────────────────
    await query(`
      CREATE TABLE IF NOT EXISTS checkouts (
        id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        product_id  UUID REFERENCES products(id) ON DELETE CASCADE,
        user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
        approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
        status      TEXT NOT NULL DEFAULT 'pending',
        due_date    DATE,
        returned_at TIMESTAMP,
        notes       TEXT,
        created_at  TIMESTAMP DEFAULT NOW()
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_checkouts_product ON checkouts(product_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_checkouts_user    ON checkouts(user_id);`);

    // ── Maintenance tasks ─────────────────────────────────────────────────────
    await query(`
      CREATE TABLE IF NOT EXISTS maintenance_tasks (
        id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        product_id     UUID REFERENCES products(id) ON DELETE CASCADE,
        created_by     UUID REFERENCES users(id) ON DELETE SET NULL,
        assigned_to    UUID REFERENCES users(id) ON DELETE SET NULL,
        title          TEXT NOT NULL,
        description    TEXT,
        priority       TEXT NOT NULL DEFAULT 'medium',
        status         TEXT NOT NULL DEFAULT 'scheduled',
        scheduled_date DATE,
        completed_at   TIMESTAMP,
        created_at     TIMESTAMP DEFAULT NOW()
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_maint_product ON maintenance_tasks(product_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_maint_assigned ON maintenance_tasks(assigned_to);`);

    // ── Maintenance notes ─────────────────────────────────────────────────────
    await query(`
      CREATE TABLE IF NOT EXISTS maintenance_notes (
        id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        task_id    UUID REFERENCES maintenance_tasks(id) ON DELETE CASCADE,
        user_id    UUID REFERENCES users(id) ON DELETE SET NULL,
        note       TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_notes_task ON maintenance_notes(task_id);`);

    // ── Low stock threshold ───────────────────────────────────────────────────
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS low_stock_threshold INTEGER DEFAULT 1;`);

    // ── Transfer requests ─────────────────────────────────────────────────────
    await query(`
      CREATE TABLE IF NOT EXISTS transfer_requests (
        id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        product_id    UUID REFERENCES products(id) ON DELETE CASCADE,
        requested_by  UUID REFERENCES users(id) ON DELETE SET NULL,
        from_room_id  UUID REFERENCES rooms(id) ON DELETE SET NULL,
        to_room_id    UUID REFERENCES rooms(id) ON DELETE SET NULL,
        status        TEXT NOT NULL DEFAULT 'pending',
        notes         TEXT,
        resolved_by   UUID REFERENCES users(id) ON DELETE SET NULL,
        resolved_at   TIMESTAMP,
        created_at    TIMESTAMP DEFAULT NOW()
      );
    `);
    await query(`CREATE INDEX IF NOT EXISTS idx_transfer_product ON transfer_requests(product_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_transfer_user    ON transfer_requests(requested_by);`);

    // ── Warranty & lifecycle fields ───────────────────────────────────────────
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS purchase_date   DATE;`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS warranty_expiry DATE;`);
    await query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS end_of_life_date DATE;`);

    // ── Recurring maintenance ─────────────────────────────────────────────────
    await query(`ALTER TABLE maintenance_tasks ADD COLUMN IF NOT EXISTS recurrence_interval_days INTEGER;`);

    console.log("✅ Database migration completed");
    process.exit(0);
  } catch (err) {
    console.error("❌ Migration failed:", err);
    process.exit(1);
  }
};

migrate();
