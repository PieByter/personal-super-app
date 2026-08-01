# Personal Super App

Aplikasi super pribadi dengan 10 modul untuk mengelola seluruh aspek kehidupan: keuangan, produktivitas, karir, dan pembelajaran.

## Arsitektur

```
personal-super-app/
├── backend/          # Next.js + Drizzle ORM + PostgreSQL
│   ├── src/app/api/  # REST API endpoints
│   └── src/db/       # Database schema & connection
├── mobile/           # Flutter (iOS, Android, Web)
│   ├── lib/presentation/modules/  # 10 module screens
│   └── lib/data/     # API service & local DB
└── database/         # PostgreSQL schema.sql
```

## 10 Modules

| # | Module | Description | Color |
|---|--------|-------------|-------|
| 1 | **Finance** | Income/expense, budgets, saving goals, investments | 🟢 Green |
| 2 | **Dashboard** | Personal life overview & quick access | ⚪ Slate |
| 3 | **Developer Journal** | Problem-solution database with tags | 🟣 Indigo |
| 4 | **Bug Tracker** | Error tracking with statistics | 🔴 Red |
| 5 | **Job Tracker** | Application pipeline & interviews | 🔵 Blue |
| 6 | **Project Manager** | Goals, milestones, tasks, progress | 🟣 Purple |
| 7 | **Habit Tracker** | Daily habits & productivity metrics | 🟡 Amber |
| 8 | **Subscriptions** | Recurring costs & renewal reminders | 🩷 Pink |
| 9 | **Inventory** | Personal items with warranty tracking | 🟢 Teal |
| 10 | **Bookmarks** | Resource manager with collections | 🟠 Orange |

## Tech Stack

### Backend (Vercel Ready)
- **Next.js 15** - API Routes (Serverless)
- **Drizzle ORM** - Type-safe SQL
- **PostgreSQL** - Database (Supabase/Neon/Vercel Postgres)
- **JWT Auth** - Stateless authentication
- **Zod** - Request validation

### Mobile
- **Flutter 3.5+** - Cross-platform
- **Go Router** - Navigation
- **BLoC Pattern** - State management
- **sqflite** - Offline-first local DB
- **Shared Preferences** - Token storage

## Getting Started

### Backend
```bash
cd backend
cp .env.example .env
# Edit .env with your DATABASE_URL and JWT_SECRET
npm install
npm run db:migrate
npm run dev
```

### Mobile
```bash
cd mobile
flutter pub get
flutter run
```

### Database Setup
```bash
# Using psql or Supabase SQL Editor
psql -d your_database -f database/schema.sql
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth` | POST | Login / Register |
| `/api/dashboard` | GET | Aggregated dashboard data |
| `/api/finance/transactions` | GET/POST | List / Create transactions |
| `/api/journal` | GET/POST | Journal entries |
| `/api/bugs` | GET/POST | Bug entries |
| `/api/jobs` | GET/POST | Job applications |
| `/api/projects` | GET/POST | Projects |
| `/api/habits` | GET/POST | Habits & logs |
| `/api/subscriptions` | GET/POST | Subscriptions |
| `/api/inventory` | GET/POST | Inventory items |
| `/api/bookmarks` | GET/POST | Bookmarks |

## Deployment

### Backend to Vercel
```bash
cd backend
vercel --prod
```

### Environment Variables (Vercel)
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Random secret for token signing

## Features

- ✅ JWT Authentication
- ✅ Row Level Security (RLS) ready for Supabase
- ✅ Offline-first with SQLite sync
- ✅ Comprehensive database schema with indexes
- ✅ Dashboard with aggregated metrics
- ✅ Modular architecture for easy extension
- ✅ Type-safe API with Zod validation
- ✅ Clean Architecture in Flutter

## Roadmap

- [ ] CSV import for bank statements
- [ ] Push notifications for reminders
- [ ] Biometric authentication
- [ ] Data export (JSON/CSV)
- [ ] Dark mode support
- [ ] Charts & visualizations
- [ ] Recurring transaction automation
- [ ] Investment price tracking
