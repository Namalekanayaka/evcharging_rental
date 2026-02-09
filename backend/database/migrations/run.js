import db from "../config/database.js";

export const runMigrations = async () => {
  try {
    console.log("🔄 Running database migrations...");

    // Create enum types
    await db.query(`
      DO $$ BEGIN
        CREATE TYPE user_type_enum AS ENUM ('driver', 'charger_owner', 'admin');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    await db.query(`
      DO $$ BEGIN
        CREATE TYPE booking_status_enum AS ENUM ('pending', 'confirmed', 'in-progress', 'completed', 'cancelled');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);

    // Create users table
    await db.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) UNIQUE,
        password VARCHAR(255) NOT NULL,
        first_name VARCHAR(100),
        last_name VARCHAR(100),
        user_type user_type_enum DEFAULT 'driver',
        profile_image VARCHAR(500),
        bio TEXT,
        is_verified BOOLEAN DEFAULT false,
        verified_at TIMESTAMP,
        status VARCHAR(50) DEFAULT 'active',
        suspension_reason TEXT,
        average_rating DECIMAL(3,2),
        total_reviews INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
      CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
      CREATE INDEX IF NOT EXISTS idx_users_user_type ON users(user_type);
    `);

    // Create chargers table
    await db.query(`
      CREATE TABLE IF NOT EXISTS chargers (
        id SERIAL PRIMARY KEY,
        owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        type VARCHAR(100),
        address VARCHAR(500),
        latitude DECIMAL(10, 8),
        longitude DECIMAL(11, 8),
        price_per_hour DECIMAL(10, 2),
        connector_types JSONB,
        max_wattage INTEGER,
        availability JSONB,
        images JSONB,
        status VARCHAR(50) DEFAULT 'active',
        disabled_reason TEXT,
        average_rating DECIMAL(3,2),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_chargers_owner_id ON chargers(owner_id);
      CREATE INDEX IF NOT EXISTS idx_chargers_status ON chargers(status);
      CREATE INDEX IF NOT EXISTS idx_chargers_location ON chargers(latitude, longitude);
    `);

    // Create bookings table
    await db.query(`
      CREATE TABLE IF NOT EXISTS bookings (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
        owner_id INTEGER NOT NULL REFERENCES users(id),
        start_time TIMESTAMP NOT NULL,
        end_time TIMESTAMP NOT NULL,
        duration INTEGER,
        total_amount DECIMAL(10, 2),
        status booking_status_enum DEFAULT 'pending',
        cancellation_reason TEXT,
        confirmed_at TIMESTAMP,
        completed_at TIMESTAMP,
        cancelled_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
      CREATE INDEX IF NOT EXISTS idx_bookings_charger_id ON bookings(charger_id);
      CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
      CREATE INDEX IF NOT EXISTS idx_bookings_start_time ON bookings(start_time);
    `);

    // Create wallets table
    await db.query(`
      CREATE TABLE IF NOT EXISTS wallets (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
        balance DECIMAL(15, 2) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);
    `);

    // Create wallet transactions table
    await db.query(`
      CREATE TABLE IF NOT EXISTS wallet_transactions (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        amount DECIMAL(15, 2),
        type VARCHAR(50),
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_wallet_trans_user_id ON wallet_transactions(user_id);
      CREATE INDEX IF NOT EXISTS idx_wallet_trans_created ON wallet_transactions(created_at);
    `);

    // Create payments table
    await db.query(`
      CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        booking_id INTEGER NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
        amount DECIMAL(10, 2),
        payment_method VARCHAR(100),
        status VARCHAR(50) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
      CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
      CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
    `);

    // Create reviews table
    await db.query(`
      CREATE TABLE IF NOT EXISTS reviews (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
        booking_id INTEGER REFERENCES bookings(id),
        rating INTEGER,
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
      CREATE INDEX IF NOT EXISTS idx_reviews_charger_id ON reviews(charger_id);
      CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating);
    `);

    // Create OTP codes table
    await db.query(`
      CREATE TABLE IF NOT EXISTS otp_codes (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        code VARCHAR(10),
        expires_at TIMESTAMP,
        is_used BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_otp_user_id ON otp_codes(user_id);
    `);

    // Create pricing packages table
    await db.query(`
      CREATE TABLE IF NOT EXISTS pricing_packages (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255),
        description TEXT,
        base_price DECIMAL(10, 2),
        hourly_rate DECIMAL(10, 2),
        benefits JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create charger availability table
    await db.query(`
      CREATE TABLE IF NOT EXISTS charger_availability (
        id SERIAL PRIMARY KEY,
        charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
        date DATE,
        time_slot VARCHAR(100),
        is_available BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
      CREATE INDEX IF NOT EXISTS idx_charger_avail_charger ON charger_availability(charger_id);
    `);

    // Create admin reports table
    await db.query(`
      CREATE TABLE IF NOT EXISTS admin_reports (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255),
        description TEXT,
        type VARCHAR(100),
        status VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    console.log("✓ Database migrations completed successfully");
    return true;
  } catch (error) {
    console.error("✗ Migration error:", error);
    throw error;
  }
};

export default runMigrations;
