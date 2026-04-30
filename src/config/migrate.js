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
      ON CONFLICT DO NOTHING;
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
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);

    await query(`CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_user ON products(user_id);`);
    await query(`CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);`);

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

    console.log("✅ Database migration completed");
    process.exit(0);
  } catch (err) {
    console.error("❌ Migration failed:", err);
    process.exit(1);
  }
};

migrate();
