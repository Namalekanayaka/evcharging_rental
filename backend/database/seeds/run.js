import db from "../../src/config/database.js";

export const seedDatabase = async () => {
  try {
    console.log("🌱 Seeding database...");

    // Seed admin user
    await db.query(`
      INSERT INTO users (email, phone, password, first_name, last_name, user_type, is_verified, verified_at)
      VALUES ('admin@evcharging.com', '+1234567890', '$2a$10$Rr8GW0VmL8K0UqM9.qZ0JO1j7JnQqZ0Lkq5QkQ9lL0L9LkK9l.ym2', 'Admin', 'User', 'admin', true, NOW())
      ON CONFLICT (email) DO NOTHING;
    `);

    // Seed charger owner
    await db.query(`
      INSERT INTO users (email, phone, password, first_name, last_name, user_type, is_verified, verified_at)
      VALUES ('owner@evcharging.com', '+1987654321', '$2a$10$Rr8GW0VmL8K0UqM9.qZ0JO1j7JnQqZ0Lkq5QkQ9lL0L9LkK9l.ym2', 'John', 'Owner', 'charger_owner', true, NOW())
      ON CONFLICT (email) DO NOTHING;
    `);

    // Seed regular users
    await db.query(`
      INSERT INTO users (email, phone, password, first_name, last_name, user_type, is_verified, verified_at)
      VALUES 
        ('driver1@evcharging.com', '+1111111111', '$2a$10$Rr8GW0VmL8K0UqM9.qZ0JO1j7JnQqZ0Lkq5QkQ9lL0L9LkK9l.ym2', 'Alice', 'Driver', 'driver', true, NOW()),
        ('driver2@evcharging.com', '+1222222222', '$2a$10$Rr8GW0VmL8K0UqM9.qZ0JO1j7JnQqZ0Lkq5QkQ9lL0L9LkK9l.ym2', 'Bob', 'Driver', 'driver', true, NOW())
      ON CONFLICT (email) DO NOTHING;
    `);

    // Create wallets for users
    await db.query(`
      INSERT INTO wallets (user_id, balance)
      SELECT DISTINCT u.id, 500 FROM users u
      WHERE NOT EXISTS (SELECT 1 FROM wallets w WHERE w.user_id = u.id);
    `);

    // Seed sample chargers
    const ownerId = await db.one(
      `SELECT id FROM users WHERE email = 'owner@evcharging.com'`,
    );

    await db.query(`
      INSERT INTO chargers (owner_id, name, description, type, address, latitude, longitude, price_per_hour, connector_types, max_wattage, status)
      VALUES 
        ($1, 'Downtown Fast Charger', 'Type 2 super fast charger in downtown area', 'DC', '123 Main St, City Center', 40.7128, -74.0060, 5.99, '["Type2", "CCS"]'::jsonb, 350, 'active'),
        ($1, 'Airport Charging Hub', 'Multiple chargers near airport terminal', 'AC', 'Airport Avenue, Terminal 2', 40.7769, -73.8740, 3.49, '["Type2"]'::jsonb, 50, 'active'),
        ($1, 'Mall Parking Charger', 'Convenient charger in underground parking', 'AC', 'Shopping Mall, Parking Level 3', 40.7580, -73.9855, 2.99, '["Type2"]'::jsonb, 22, 'active')
      ON CONFLICT DO NOTHING;
    `);

    // Seed pricing packages
    await db.query(`
      INSERT INTO pricing_packages (name, description, base_price, hourly_rate, benefits)
      VALUES 
        ('Basic', 'Standard charging service', 0, 2.99, '["Access to all chargers", "User support"]'::jsonb),
        ('Premium', 'Fast charging with priority', 9.99, 4.99, '["Priority access", "Fast charging", "Monthly discount", "24/7 support"]'::jsonb),
        ('Fleet', 'Business fleet management', 49.99, 3.99, '["Multiple drivers", "Fleet tracking", "Volume discount", "Dedicated support"]'::jsonb)
      ON CONFLICT DO NOTHING;
    `);

    console.log("✓ Database seeding completed successfully");
    return true;
  } catch (error) {
    console.error("✗ Seeding error:", error);
    throw error;
  }
};

export default seedDatabase;
