import pgPromise from "pg-promise";
import dotenv from "dotenv";

dotenv.config();

const initOptions = {
  error: (error) => {
    console.error("Database error:", error.message);
  },
};

const pgp = pgPromise(initOptions);

const connection = {
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT || "5432"),
  database: process.env.DB_NAME || "evcharging_rental_db",
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD || "postgres",
  max: parseInt(process.env.DB_POOL_MAX || "10"),
  min: parseInt(process.env.DB_POOL_MIN || "2"),
};

const db = pgp(connection);

// Test connection
export const testConnection = async () => {
  try {
    await db.query("SELECT NOW()");
    console.log("✓ Database connection successful");
    return true;
  } catch (error) {
    console.error("✗ Database connection failed:", error.message);
    return false;
  }
};

export default db;
