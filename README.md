# EV Charger Rental Platform

A complete peer-to-peer EV charger rental platform (like Airbnb for EV charging) built with **Node.js + Express** backend, **Flutter** mobile app, and **PostgreSQL** database.

## 🚀 Features

### Core Features

- ✅ User authentication with JWT & OTP verification
- ✅ Charger listing and management
- ✅ Booking system with real-time availability
- ✅ Integrated wallet & payment system
- ✅ Review and rating system
- ✅ Location-based search with Google Maps
- ✅ Admin dashboard with analytics
- ✅ Role-based access control (RBAC)
- ✅ Push notifications (Firebase ready)

### User Types

1. **Drivers** - Search and book chargers
2. **Charger Owners** - List and manage chargers
3. **Admins** - Manage platform and users

---

## 🏗️ Architecture

### Technology Stack

| Component         | Technology                     |
| ----------------- | ------------------------------ |
| **Backend**       | Node.js 18+ + Express.js 4.18+ |
| **Mobile**        | Flutter 3.10+                  |
| **Database**      | PostgreSQL 12+                 |
| **Auth**          | JWT + OTP                      |
| **Maps**          | Google Maps API                |
| **Notifications** | Firebase Cloud Messaging       |
| **Deployment**    | Docker + Docker Compose        |

### Project Structure

```
ev-charging-rental/
├── backend/              # Node.js + Express API
│   ├── src/
│   │   ├── config/      # Database, JWT, Email config
│   │   ├── middleware/  # Auth, Role, Error handling
│   │   ├── modules/     # 8 feature modules
│   │   │   ├── auth/
│   │   │   ├── user/
│   │   │   ├── charger/
│   │   │   ├── booking/
│   │   │   ├── payment/
│   │   │   ├── wallet/
│   │   │   ├── review/
│   │   │   ├── pricing/
│   │   │   └── admin/
│   │   ├── routes/
│   │   ├── utils/
│   │   └── server.js
│   ├── database/        # Migrations & Seeds
│   ├── tests/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── package.json
│   └── .env.example
│
├── mobile/              # Flutter App (Clean Architecture)
│   ├── lib/
│   │   ├── core/       # Theme, Constants, Errors
│   │   ├── data/       # Models, DataSources, Repositories
│   │   ├── domain/     # Entities, Use Cases
│   │   ├── presentation/ # UI, BLoCs, Pages
│   │   ├── injection_container.dart
│   │   └── main.dart
│   ├── assets/
│   └── pubspec.yaml
│
├── docs/                # Documentation
│   ├── ER_DIAGRAM.md
│   ├── API_DOCS.md
│   └── SETUP_GUIDE.md
│
├── COMPLETE_DOCUMENTATION.md
└── README.md (this file)
```

---

## 📋 Quick Start

### Prerequisites

- **Node.js** 18.0+ with npm
- **PostgreSQL** 12+
- **Flutter** 3.10+
- **Docker** & **Docker Compose** (optional)
- **Git**

### 1. Backend Setup (5 minutes)

```bash
# Clone repository
git clone <repo-url>
cd ev-charging-rental/backend

# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env with your database credentials and API keys

# Create database
createdb evcharging_rental_db

# Run migrations
npm run db:migrate

# Seed sample data
npm run db:seed

# Start development server
npm run dev
```

✅ Backend running on `http://localhost:5000`

### 2. Mobile Setup (5 minutes)

```bash
# Navigate to mobile folder
cd ../mobile

# Get dependencies
flutter pub get

# Configure API endpoint
# Edit lib/core/constants/api_constants.dart
# Update apiBaseUrl to http://localhost:5000/api

# Run app
flutter run
```

✅ App running on your device/emulator

### 3. Docker Setup (Alternative - 3 minutes)

```bash
cd backend

# Start all services with Docker Compose
docker-compose up -d

# Check services
docker-compose ps

# Stop services
docker-compose down
```

✅ PostgreSQL on port 5432, Backend on port 5000

---

## 📱 API Endpoints

### Authentication

```
POST   /api/auth/register          - User registration
POST   /api/auth/verify-otp        - Verify email OTP
POST   /api/auth/login             - User login
POST   /api/auth/resend-otp        - Resend OTP
POST   /api/auth/refresh-token     - Refresh JWT
```

### Users

```
GET    /api/users/profile          - Get user profile
PUT    /api/users/profile          - Update profile
GET    /api/users/stats            - Get user statistics
GET    /api/users/bookings         - Get user bookings
PUT    /api/users/change-password  - Change password
```

### Chargers

```
GET    /api/chargers/search        - Search chargers (location, price)
GET    /api/chargers/:id           - Get charger details
POST   /api/chargers               - Create new charger (owner)
PUT    /api/chargers/:id           - Update charger (owner)
DELETE /api/chargers/:id           - Delete charger (owner)
GET    /api/chargers/:id/availability - Check availability
```

### Bookings

```
POST   /api/bookings               - Create booking
GET    /api/bookings               - Get user bookings
GET    /api/bookings/:id           - Get booking details
PATCH  /api/bookings/:id/confirm   - Confirm booking
PATCH  /api/bookings/:id/cancel    - Cancel booking
GET    /api/bookings/history       - Get completed bookings
```

### Wallet & Payments

```
GET    /api/wallet                 - Get wallet balance
POST   /api/wallet/add-balance     - Add money to wallet
POST   /api/wallet/transfer        - Transfer money to user
GET    /api/wallet/transactions    - Get transaction history
POST   /api/payments               - Process payment
GET    /api/payments               - Get user payments
POST   /api/payments/:id/refund    - Refund payment
```

### Reviews

```
POST   /api/reviews                - Create review
GET    /api/reviews/charger/:id    - Get charger reviews
GET    /api/reviews/charger/:id/stats - Get review statistics
PUT    /api/reviews/:id            - Update review
DELETE /api/reviews/:id            - Delete review
```

### Pricing

```
GET    /api/pricing                - Get pricing packages
POST   /api/pricing/calculate      - Calculate booking price
GET    /api/pricing/admin/stats    - Get pricing statistics (admin)
```

### Admin

```
GET    /api/admin/dashboard/stats  - Dashboard statistics
GET    /api/admin/users            - List all users
GET    /api/admin/chargers         - List all chargers
GET    /api/admin/bookings         - List all bookings
PATCH  /api/admin/users/:id/suspend - Suspend user
PATCH  /api/admin/users/:id/activate - Activate user
GET    /api/admin/revenue/timeline - Revenue analytics
```

---

## 🗄️ Database Schema

### Key Tables

**users** - All platform users

- id, email, phone, password, first_name, last_name, user_type, is_verified, average_rating

**chargers** - EV charging stations

- id, owner_id, name, address, latitude, longitude, price_per_hour, connector_types, status

**bookings** - Charging sessions

- id, user_id, charger_id, start_time, end_time, duration, total_amount, status

**wallets** - User wallet balances

- id, user_id, balance

**payments** - Payment records

- id, user_id, booking_id, amount, payment_method, status

**reviews** - User reviews of chargers

- id, user_id, charger_id, rating, comment

**otp_codes** - OTP verification codes

- id, user_id, code, expires_at, is_used

See `COMPLETE_DOCUMENTATION.md` for full schema details and ER diagram.

---

## 🔐 Environment Configuration

Create `.env` file in backend directory:

```env
# Server
NODE_ENV=development
PORT=5000
API_URL=http://localhost:5000

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=evcharging_rental_db
DB_USER=postgres
DB_PASSWORD=postgres

# JWT
JWT_SECRET=your_super_secret_key_change_in_production
JWT_EXPIRE=7d

# Email (Gmail)
SMTP_HOST=smtp.gmail.com
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password

# Google Maps
GOOGLE_MAPS_API_KEY=your_api_key

# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email
```

---

## 🧪 Testing

### Backend Tests

```bash
npm run test              # Run all tests
npm run test:watch       # Watch mode
npm run lint             # Run linter
```

### Mobile Tests

```bash
flutter test             # Run unit tests
flutter test --coverage  # With coverage report
```

---

## 📦 Building for Production

### Backend

```bash
# Create optimized Docker image
docker build -t evcharging-backend:latest .

# Push to registry
docker push your-registry/evcharging-backend:latest
```

### Mobile

**iOS:**

```bash
flutter build ios --release
# Upload to TestFlight/App Store via Xcode
```

**Android:**

```bash
flutter build appbundle --release
# Upload APK to Google Play Store
```

---

## 🚀 Deployment

### AWS Deployment

1. Set up RDS PostgreSQL instance
2. Deploy Docker container to ECS/EC2
3. Configure CloudFront CDN
4. Set up SSL certificates with ACM
5. Configure RDS backups

### Production Checklist

- [ ] All environment variables set
- [ ] Database backups configured
- [ ] SSL certificates installed
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Monitoring set up
- [ ] Backup/disaster recovery plan
- [ ] Security audit completed

---

## 📊 Architecture Highlights

### Clean Architecture (Mobile)

- **Domain Layer** - Business logic & entities
- **Data Layer** - Repositories & data sources
- **Presentation Layer** - UI & state management (BLoC)

### Modular MVC (Backend)

- **Controllers** - Handle HTTP requests
- **Services** - Business logic
- **Models** - Database schemas
- **Routes** - API endpoints
- **Middleware** - Authentication, validation, error handling

### Database Features

- PostgreSQL with proper indexing
- Migration system for schema changes
- Seed data for testing
- Spatial queries for location-based search

---

## 🎯 Development Roadmap

### Phase 1 ✅ (Current)

- Core authentication & user management
- Charger listing & search
- Booking system
- Wallet & payment integration

### Phase 2 (Planned)

- Advanced search filters
- Real-time notifications
- Message system between users
- Subscription plans
- Analytics dashboard

### Phase 3 (Future)

- AI-based charger recommendations
- Dynamic pricing algorithm
- Integration with actual payment gateways
- Fleet management for businesses
- Smart charger hardware integration

---

## 🔒 Security Features

- ✅ JWT-based authentication
- ✅ OTP email verification
- ✅ Password hashing with bcrypt
- ✅ Role-based access control (RBAC)
- ✅ Input validation & sanitization
- ✅ Rate limiting on API endpoints
- ✅ CORS configuration
- ✅ SQL injection protection (parameterized queries)

---

## 📖 Documentation

- **[COMPLETE_DOCUMENTATION.md](./COMPLETE_DOCUMENTATION.md)** - Full API docs, architecture, and setup guide
- **[ER_DIAGRAM.md](./docs/ER_DIAGRAM.md)** - Database schema with relationships
- **[API_DOCS.md](./docs/API_DOCS.md)** - Detailed endpoint documentation
- **[Code Comments](./backend/src)** - Inline documentation in code

---

## 🐛 Troubleshooting

### Backend Issues

**Port 5000 already in use:**

```bash
lsof -i :5000
kill -9 <PID>
```

**Database connection error:**

```bash
# Check PostgreSQL is running
sudo service postgresql status

# Check credentials in .env
# Ensure database exists
createdb evcharging_rental_db
```

### Mobile Issues

**Flutter build fails:**

```bash
flutter clean
flutter pub get
flutter run
```

**API connection error:**

- Check backend is running on http://localhost:5000
- Update apiBaseUrl in `lib/core/constants/api_constants.dart`
- Check network connectivity

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

## 👨‍💼 Support

For support, email support@evcharging.com or create an issue on GitHub.

---

## 🙏 Acknowledgments

- Express.js documentation
- Flutter best practices
- PostgreSQL optimization guides
- Firebase documentation

---

**Made with ❤️ by the EV Charging Platform Team**

_Last Updated: December 2024_
