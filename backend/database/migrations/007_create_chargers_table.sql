-- ============================================
-- Charger Management Schema
-- ============================================

-- Chargers table
CREATE TABLE IF NOT EXISTS chargers (
  id SERIAL PRIMARY KEY,
  owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  charger_type VARCHAR(50) NOT NULL CHECK(charger_type IN ('AC', 'DC', 'FAST')),
  power_kw DECIMAL(5, 2) NOT NULL,
  
  -- Location information
  address VARCHAR(500) NOT NULL,
  city VARCHAR(100) NOT NULL,
  state VARCHAR(100) NOT NULL,
  postal_code VARCHAR(20),
  country VARCHAR(100) DEFAULT 'USA',
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  
  -- Pricing and availability
  price_per_kwh DECIMAL(8, 2),
  price_per_hour DECIMAL(8, 2),
  
  -- Status
  status VARCHAR(50) DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE', 'BUSY', 'OFFLINE', 'MAINTENANCE')),
  
  -- Features
  allow_reservations BOOLEAN DEFAULT true,
  reservation_time_limit INTEGER, -- minutes
  
  -- Metadata
  is_public BOOLEAN DEFAULT true,
  total_sessions INTEGER DEFAULT 0,
  avg_rating DECIMAL(3, 2),
  total_reviews INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEXES (owner_id, status, city, latitude, longitude)
);

-- Charger availability schedule
CREATE TABLE IF NOT EXISTS charger_availability (
  id SERIAL PRIMARY KEY,
  charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK(day_of_week BETWEEN 0 AND 6), -- 0=Sunday, 6=Saturday
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_available BOOLEAN DEFAULT true,
  
  UNIQUE(charger_id, day_of_week),
  INDEXES (charger_id, day_of_week)
);

-- Charger usage history
CREATE TABLE IF NOT EXISTS charger_usage_history (
  id SERIAL PRIMARY KEY,
  charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
  booking_id INTEGER REFERENCES bookings(id) ON DELETE SET NULL,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  
  -- Session details
  session_start TIMESTAMP NOT NULL,
  session_end TIMESTAMP,
  duration_minutes INTEGER,
  
  -- Energy data
  energy_consumed_kwh DECIMAL(10, 2),
  cost DECIMAL(10, 2),
  
  -- Status
  status VARCHAR(50) DEFAULT 'IN_PROGRESS' CHECK(status IN ('IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
  
  -- Notes
  notes TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEXES (charger_id, user_id, session_start, status)
);

-- Charger reviews and ratings
CREATE TABLE IF NOT EXISTS charger_reviews (
  id SERIAL PRIMARY KEY,
  charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
  reviewer_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  booking_id INTEGER REFERENCES bookings(id) ON DELETE SET NULL,
  
  rating INTEGER NOT NULL CHECK(rating BETWEEN 1 AND 5),
  review_title VARCHAR(255),
  review_text TEXT,
  
  -- Review aspects
  cleanliness_rating INTEGER CHECK(cleanliness_rating BETWEEN 1 AND 5),
  functionality_rating INTEGER CHECK(functionality_rating BETWEEN 1 AND 5),
  location_rating INTEGER CHECK(location_rating BETWEEN 1 AND 5),
  
  helpful_count INTEGER DEFAULT 0,
  total_ratings INTEGER DEFAULT 0,
  
  is_verified_purchase BOOLEAN DEFAULT false,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEXES (charger_id, reviewer_id, created_at, rating)
);

-- Charger photos
CREATE TABLE IF NOT EXISTS charger_photos (
  id SERIAL PRIMARY KEY,
  charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
  photo_url VARCHAR(500) NOT NULL,
  display_order INTEGER DEFAULT 0,
  is_primary BOOLEAN DEFAULT false,
  
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEXES (charger_id, is_primary)
);

-- Charger maintenance log
CREATE TABLE IF NOT EXISTS charger_maintenance (
  id SERIAL PRIMARY KEY,
  charger_id INTEGER NOT NULL REFERENCES chargers(id) ON DELETE CASCADE,
  maintenance_type VARCHAR(100) NOT NULL,
  description TEXT,
  scheduled_date DATE,
  completed_date DATE,
  notes TEXT,
  
  status VARCHAR(50) DEFAULT 'SCHEDULED' CHECK(status IN ('SCHEDULED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEXES (charger_id, status, scheduled_date)
);

-- Create indexes for performance
CREATE INDEX idx_chargers_owner_id ON chargers(owner_id);
CREATE INDEX idx_chargers_status ON chargers(status);
CREATE INDEX idx_chargers_location ON chargers(latitude, longitude);
CREATE INDEX idx_chargers_city ON chargers(city);
CREATE INDEX idx_charger_availability_charger_id ON charger_availability(charger_id);
CREATE INDEX idx_charger_usage_charger_id ON charger_usage_history(charger_id);
CREATE INDEX idx_charger_usage_user_id ON charger_usage_history(user_id);
CREATE INDEX idx_charger_reviews_charger_id ON charger_reviews(charger_id);
CREATE INDEX idx_charger_photos_charger_id ON charger_photos(charger_id);
CREATE INDEX idx_charger_maintenance_charger_id ON charger_maintenance(charger_id);

-- Create view for charger listings with owner info
CREATE OR REPLACE VIEW charger_listings AS
SELECT 
  c.id,
  c.owner_id,
  c.name,
  c.description,
  c.charger_type,
  c.power_kw,
  c.address,
  c.city,
  c.state,
  c.postal_code,
  c.country,
  c.latitude,
  c.longitude,
  c.price_per_kwh,
  c.price_per_hour,
  c.status,
  c.allow_reservations,
  c.is_public,
  c.avg_rating,
  c.total_reviews,
  c.total_sessions,
  c.created_at,
  u.first_name AS owner_first_name,
  u.last_name AS owner_last_name,
  u.average_rating AS owner_rating,
  u.total_reviews AS owner_reviews
FROM chargers c
JOIN users u ON c.owner_id = u.id
WHERE c.is_public = true;

-- Create view for charger availability status
CREATE OR REPLACE VIEW charger_status_view AS
SELECT 
  c.id,
  c.name,
  c.status,
  c.latitude,
  c.longitude,
  COALESCE(ca.start_time, '00:00:00') AS today_start_time,
  COALESCE(ca.end_time, '23:59:59') AS today_end_time,
  COALESCE(ca.is_available, true) AS available_today,
  COUNT(cuh.id) AS active_sessions
FROM chargers c
LEFT JOIN charger_availability ca ON c.id = ca.charger_id 
  AND ca.day_of_week = EXTRACT(DOW FROM CURRENT_DATE)
LEFT JOIN charger_usage_history cuh ON c.id = cuh.charger_id 
  AND cuh.status = 'IN_PROGRESS'
GROUP BY c.id, c.name, c.status, c.latitude, c.longitude, ca.start_time, ca.end_time, ca.is_available;
