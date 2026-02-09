# EV Charger Rental Platform - Complete Documentation

## Table of Contents

1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [API Documentation](#api-documentation)
5. [Installation & Setup](#installation--setup)
6. [Development Guide](#development-guide)
7. [Deployment](#deployment)

---

## System Overview

EV Charger Rental is a peer-to-peer marketplace platform for EV charging, similar to Airbnb but for electric vehicle charging stations. The platform connects EV charger owners with drivers who need to charge their vehicles.

### Key Features:

- **User Management**: Registration, authentication, and profile management
- **Charger Listing**: Owners can list and manage their charging stations
- **Booking System**: Drivers can search, book, and pay for charging sessions
- **Wallet & Payments**: Integrated wallet system with transactions history
- **Reviews & Ratings**: Quality assurance through user reviews
- **Admin Dashboard**: Platform management and monitoring
- **Location-based Search**: Find chargers near your location
- **Real-time Mapping**: Google Maps integration

---

## Architecture

### Tech Stack

- **Backend**: Node.js + Express.js
- **Frontend**: Flutter (Clean Architecture)
- **Database**: PostgreSQL
- **Authentication**: JWT + OTP
- **Maps**: Google Maps API
- **Notifications**: Firebase Cloud Messaging
- **Payment**: Wallet Mock (can be replaced with Stripe/PayPal)
- **Containerization**: Docker & Docker Compose

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Layer                         │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │  Flutter App   │  │   Web Client   │  │  Admin Panel │  │
│  │  - Auth        │  │  (Optional)    │  │              │  │
│  │  - Dashboard   │  │                │  │              │  │
│  │  - Booking     │  │                │  │              │  │
│  └────────────────┘  └────────────────┘  └──────────────┘  │
└──────────────┬────────────────────────────────────────────┬─┘
               │                                            │
             HTTPS/REST API                            WebSocket
               │                                            │
┌──────────────┴────────────────────────────────────────────┴─┐
│                      API Layer (Node.js)                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  API Routes & Controllers                            │  │
│  │  - /auth         - /chargers     - /bookings         │  │
│  │  - /users        - /wallet       - /payments         │  │
│  │  - /reviews      - /pricing      - /admin            │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Middleware                                          │  │
│  │  - Authentication (JWT)  - Authorization (RBAC)     │  │
│  │  - Error Handling        - Rate Limiting            │  │
│  │  - Request Validation    - CORS                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Business Logic (Services)                           │  │
│  │  - Authentication Service    - Booking Service      │  │
│  │  - User Service              - Payment Service      │  │
│  │  - Charger Service           - Wallet Service       │  │
│  │  - Review Service            - Admin Service        │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────┬────────────────────────────────────────────┬─┘
               │                                            │
               │                                      Firebase
               │                                      Admin SDK
               │                                            │
┌──────────────┴────────────────────────────────────────────┴─┐
│                  Data Access Layer                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database                                 │  │
│  │  - Users         - Bookings      - Reviews          │  │
│  │  - Chargers      - Payments      - Wallets          │  │
│  │  - Pricing       - Admin Reports - OTP Codes        │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## Database Schema

### Entity Relationship Diagram (Text Format)

```
┌──────────────────────┐
│      USERS           │
├──────────────────────┤
│ id (PK)              │
│ email (UNIQUE)       │
│ phone (UNIQUE)       │
│ password             │
│ first_name           │
│ last_name            │
│ user_type (ENUM)     │
│ profile_image        │
│ bio                  │
│ is_verified          │
│ verified_at          │
│ status               │
│ average_rating       │
│ total_reviews        │
│ created_at           │
│ updated_at           │
└──────────────────────┘
         │ (1:N)
         │
    ┌────┴─────────────────────────────┐
    │                                   │
    ▼                                   ▼
┌──────────────────────┐     ┌──────────────────────┐
│    CHARGERS          │     │    WALLETS           │
├──────────────────────┤     ├──────────────────────┤
│ id (PK)              │     │ id (PK)              │
│ owner_id (FK->users) │     │ user_id (FK->users)  │
│ name                 │     │ balance              │
│ description          │     │ created_at           │
│ type                 │     │ updated_at           │
│ address              │     └──────────────────────┘
│ latitude             │              │ (1:N)
│ longitude            │              │
│ price_per_hour       │              ▼
│ connector_types      │  ┌──────────────────────────┐
│ max_wattage          │  │  WALLET_TRANSACTIONS     │
│ status               │  ├──────────────────────────┤
│ created_at           │  │ id (PK)                  │
│ updated_at           │  │ user_id (FK->users)      │
└──────────────────────┘  │ amount                   │
         │ (1:N)          │ type (ENUM)              │
         │                │ description              │
         ▼                │ created_at               │
┌──────────────────────┐  └──────────────────────────┘
│    BOOKINGS          │
├──────────────────────┤
│ id (PK)              │
│ user_id (FK)         │
│ charger_id (FK)      │
│ owner_id (FK)        │
│ start_time           │
│ end_time             │
│ duration             │
│ total_amount         │
│ status (ENUM)        │
│ cancellation_reason  │
│ confirmed_at         │
│ completed_at         │
│ cancelled_at         │
│ created_at           │
│ updated_at           │
└──────────────────────┘
    │ (1:N)    │ (1:N)
    │          │
    ▼          ▼
┌──────────────┐  ┌──────────────────────┐
│   PAYMENTS   │  │    REVIEWS           │
├──────────────┤  ├──────────────────────┤
│ id (PK)      │  │ id (PK)              │
│ user_id (FK) │  │ user_id (FK)         │
│ booking_id   │  │ charger_id (FK)      │
│ amount       │  │ booking_id (FK)      │
│ payment_meth │  │ rating               │
│ status       │  │ comment              │
│ created_at   │  │ created_at           │
│ updated_at   │  │ updated_at           │
└──────────────┘  └──────────────────────┘

┌────────────────────────┐
│   PRICING_PACKAGES     │
├────────────────────────┤
│ id (PK)                │
│ name                   │
│ description            │
│ base_price             │
│ hourly_rate            │
│ benefits (JSON)        │
│ created_at             │
│ updated_at             │
└────────────────────────┘

┌──────────────────────────┐
│   OTP_CODES              │
├──────────────────────────┤
│ id (PK)                  │
│ user_id (FK->users)      │
│ code                     │
│ expires_at               │
│ is_used                  │
│ created_at               │
└──────────────────────────┘

┌──────────────────────────┐
│   CHARGER_AVAILABILITY   │
├──────────────────────────┤
│ id (PK)                  │
│ charger_id (FK)          │
│ date                     │
│ time_slot                │
│ is_available             │
│ created_at               │
└──────────────────────────┘
```

### Table Details

#### USERS

- Stores all user information (drivers, owners, admins)
- user_type ENUM: 'driver', 'charger_owner', 'admin'
- status: 'active', 'suspended', etc.

#### CHARGERS

- Information about available EV chargers
- Location data with latitude/longitude for geospatial searches
- connector_types stored as JSON array

#### BOOKINGS

- Tracks all booking transactions
- Links users to chargers
- Status tracking: pending, confirmed, in-progress, completed, cancelled

#### WALLETS

- One-to-one relationship with users
- Tracks user balance and credits

#### PAYMENTS

- Records all payment transactions
- Links to bookings and users
- Status: pending, completed, refunded

#### REVIEWS

- User feedback on chargers
- Rating (1-5) and comments

---

## API Documentation

### Authentication Endpoints

#### Register

```
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "phone": "+1234567890",
  "password": "SecurePassword123!",
  "confirmPassword": "SecurePassword123!",
  "firstName": "John",
  "lastName": "Doe",
  "userType": "driver"
}

Response (201):
{
  "success": true,
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "message": "OTP sent to your email"
  }
}
```

#### Verify OTP

```
POST /api/auth/verify-otp
Content-Type: application/json

{
  "userId": 1,
  "otp": "123456"
}

Response (200):
{
  "success": true,
  "data": {
    "user": { ... },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  },
  "message": "Email verified successfully"
}
```

#### Login

```
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}

Response (200):
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "userType": "driver"
    },
    "token": "eyJhbGciOiJIUzI1NiIs..."
  },
  "message": "Login successful"
}
```

### User Endpoints

#### Get Profile

```
GET /api/users/profile
Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "bio": "EV enthusiast",
    "profileImage": "https://...",
    "isVerified": true,
    "averageRating": 4.5,
    "totalReviews": 12
  }
}
```

#### Update Profile

```
PUT /api/users/profile
Authorization: Bearer <token>
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Smith",
  "bio": "EV enthusiast and traveler",
  "profileImage": "base64_image_data"
}

Response (200):
{
  "success": true,
  "data": { ... },
  "message": "Profile updated successfully"
}
```

### Charger Endpoints

#### Search Chargers

```
GET /api/chargers/search?latitude=40.7128&longitude=-74.0060&radius=5&minPrice=2&maxPrice=10

Response (200):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Downtown Fast Charger",
      "address": "123 Main St",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "pricePerHour": 5.99,
      "connectorTypes": ["Type2", "CCS"],
      "averageRating": 4.8,
      "totalReviews": 245
    }
  ],
  "count": 1
}
```

#### Create Charger

```
POST /api/chargers
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Fast Charging Station",
  "description": "High-speed DC charger",
  "type": "DC",
  "address": "456 Oak Ave",
  "latitude": 40.7580,
  "longitude": -73.9855,
  "pricePerHour": 5.99,
  "connectorTypes": ["CCS", "Type2"],
  "maxWattage": 350
}

Response (201):
{
  "success": true,
  "data": { ... },
  "message": "Charger created successfully"
}
```

### Booking Endpoints

#### Create Booking

```
POST /api/bookings
Authorization: Bearer <token>
Content-Type: application/json

{
  "chargerId": 1,
  "startTime": "2024-12-25T10:00:00Z",
  "duration": 2,
  "totalAmount": 11.98
}

Response (201):
{
  "success": true,
  "data": {
    "id": 1,
    "chargerId": 1,
    "startTime": "2024-12-25T10:00:00Z",
    "endTime": "2024-12-25T12:00:00Z",
    "status": "pending",
    "totalAmount": 11.98
  },
  "message": "Booking created successfully"
}
```

#### Get Bookings

```
GET /api/bookings?status=upcoming
Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "data": [ ... ],
  "count": 3
}
```

#### Cancel Booking

```
PATCH /api/bookings/1/cancel
Authorization: Bearer <token>
Content-Type: application/json

{
  "reason": "Changed my schedule"
}

Response (200):
{
  "success": true,
  "data": { ... },
  "message": "Booking cancelled"
}
```

### Wallet Endpoints

#### Get Wallet

```
GET /api/wallet
Authorization: Bearer <token>

Response (200):
{
  "success": true,
  "data": {
    "id": 1,
    "userId": 1,
    "balance": 425.50
  }
}
```

#### Add Balance

```
POST /api/wallet/add-balance
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 100.00,
  "transactionType": "credit"
}

Response (200):
{
  "success": true,
  "data": {
    "wallet": { ... },
    "transaction": { ... }
  },
  "message": "Balance added successfully"
}
```

### Review Endpoints

#### Create Review

```
POST /api/reviews
Authorization: Bearer <token>
Content-Type: application/json

{
  "chargerId": 1,
  "bookingId": 5,
  "rating": 5,
  "comment": "Excellent charger, very fast!"
}

Response (201):
{
  "success": true,
  "data": { ... },
  "message": "Review created successfully"
}
```

### Admin Endpoints

#### Get Dashboard Stats

```
GET /api/admin/dashboard/stats
Authorization: Bearer <admin_token>

Response (200):
{
  "success": true,
  "data": {
    "total_users": 1542,
    "total_drivers": 1200,
    "total_owners": 342,
    "active_chargers": 856,
    "completed_bookings": 45230,
    "pending_bookings": 134,
    "total_revenue": 245678.90,
    "avg_rating": 4.6
  }
}
```

#### Get All Users

```
GET /api/admin/users?limit=50&offset=0
Authorization: Bearer <admin_token>

Response (200):
{
  "success": true,
  "data": [ ... ],
  "count": 50
}
```

---

## Installation & Setup

### Prerequisites

- Node.js 18+ and npm
- PostgreSQL 12+
- Flutter 3.10+
- Docker & Docker Compose (optional)
- Google Maps API Key
- Firebase Account (for notifications)

### Backend Setup

1. **Clone the repository**

```bash
git clone <repository-url>
cd backend
```

2. **Install dependencies**

```bash
npm install
```

3. **Configure environment**

```bash
cp .env.example .env
# Edit .env with your configuration
```

4. **Setup database**

```bash
# Create PostgreSQL database
createdb evcharging_rental_db

# Run migrations
npm run db:migrate

# Seed database with sample data
npm run db:seed
```

5. **Start development server**

```bash
npm run dev
# Server will run on http://localhost:5000
```

### Mobile Setup

1. **Navigate to mobile directory**

```bash
cd mobile
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure API endpoint**
   - Edit `lib/core/constants/api_constants.dart`
   - Update `apiBaseUrl` to your backend URL

4. **Configure Google Maps**
   - Add your Google Maps API key to:
     - Android: `android/app/src/main/AndroidManifest.xml`
     - iOS: `ios/Runner/Info.plist`

5. **Run the app**

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Web (if supported)
flutter run -d web
```

### Docker Setup

1. **Build and run with Docker Compose**

```bash
cd backend
docker-compose up -d
```

This will start:

- PostgreSQL database on port 5432
- Backend API on port 5000

2. **Check services**

```bash
docker-compose ps
```

3. **View logs**

```bash
docker-compose logs -f backend
```

4. **Stop services**

```bash
docker-compose down
```

---

## Development Guide

### Project Structure

**Backend:**

```
backend/
├── src/
│   ├── config/          # Configuration files
│   ├── middleware/      # Custom middleware
│   ├── modules/         # Feature modules (auth, user, charger, etc.)
│   ├── routes/          # API routes
│   ├── utils/           # Utility functions
│   └── server.js        # Main server file
├── database/
│   ├── migrations/      # Database migrations
│   └── seeds/           # Sample data
├── tests/               # Test files
├── Dockerfile           # Docker configuration
├── docker-compose.yml   # Docker Compose configuration
├── package.json         # Dependencies
└── .env.example         # Environment template
```

**Mobile:**

```
mobile/
├── lib/
│   ├── core/            # Constants, theme, errors
│   ├── data/            # Models, datasources, repositories
│   ├── domain/          # Entities, repositories (interfaces), usecases
│   ├── presentation/    # BLoCs, pages, widgets
│   ├── injection_container.dart  # Dependency injection setup
│   └── main.dart        # App entry point
├── assets/              # Images, icons, fonts
└── pubspec.yaml         # Dependencies
```

### Code Standards

#### Backend

- Use ES6+ features
- Follow modular MVC pattern
- Add comprehensive error handling
- Document API endpoints
- Write unit and integration tests

#### Mobile

- Follow Clean Architecture
- Use BLoC for state management
- Keep business logic separate from UI
- Use meaningful variable names
- Document complex functions

### Adding New Features

#### Backend Example: Adding a new module

1. Create module folder: `src/modules/newFeature/`
2. Create files:
   - `newFeatureService.js` - Business logic
   - `newFeatureController.js` - Request handlers
   - `newFeatureRoutes.js` - Route definitions
3. Import routes in `src/routes/index.js`
4. Add middleware as needed

#### Mobile Example: Adding a new screen

1. Create files:
   - `lib/domain/entities/new_entity.dart`
   - `lib/data/models/new_model.dart`
   - `lib/presentation/bloc/new/new_bloc.dart`
   - `lib/presentation/pages/new_page.dart`
2. Update `injection_container.dart` if using dependencies
3. Update main navigation

---

## Deployment

### Backend Deployment to AWS

1. **Prepare for production**

```bash
# Update .env for production
# Ensure all secrets are set
# Run tests
npm run test
```

2. **Docker build**

```bash
docker build -t evcharging-backend:latest .
# Push to registry
docker push <registry>/evcharging-backend:latest
```

3. **Deploy to EC2/ECS**
   - Set up RDS PostgreSQL
   - Configure security groups
   - Pull latest image and run container

4. **Configure CDN and SSL**
   - Use CloudFront for static assets
   - Enable HTTPS with ACM certificates

### Mobile Deployment

#### iOS

```bash
# Create build
flutter build ios --release

# Upload to TestFlight/App Store
# Use Xcode or fastlane
```

#### Android

```bash
# Create signed APK
flutter build apk --split-per-abi --release

# Or create App Bundle for Play Store
flutter build appbundle --release
```

### Database Backups

```bash
# Backup PostgreSQL
pg_dump evcharging_rental_db > backup.sql

# Restore from backup
psql evcharging_rental_db < backup.sql
```

---

## Monitoring & Maintenance

### Logging

- Backend logs stored in `logs/app.log`
- Check aggregated logs in production environment

### Database Maintenance

```bash
# Analyze query performance
ANALYZE;
VACUUM;

# Check indexes
SELECT * FROM pg_stat_user_indexes;
```

### API Health Checks

```bash
curl http://localhost:5000/health
# Response: { "status": "OK", "timestamp": "..." }
```

---

## Support & Troubleshooting

### Common Issues

**Database Connection Error**

- Check PostgreSQL is running
- Verify DB credentials in .env
- Ensure database exists

**Port Already in Use**

- Change PORT in .env
- Or kill process: `lsof -i :5000`

**Flutter Build Issues**

- Run `flutter clean && flutter pub get`
- Update packages: `flutter upgrade`

### Getting Help

- Check documentation comments in code
- Review API documentation above
- Create GitHub issues for bugs

---

## License

MIT

## Contributors

- Backend Team
- Mobile Team
- DevOps Team

---
