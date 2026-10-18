# Personal Super App

Aplikasi super pribadi dengan 10 modul untuk mengelola seluruh aspek kehidupan: keuangan, produktivitas, karir, dan pembelajaran.

## Arsitektur

```text
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
| --- | -------- | ------------- | ------- |
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

### 1. Database

Easiest — Docker. It starts Postgres and applies `database/schema.sql` on the first boot:

```bash
docker compose up -d
# postgresql://user:password@localhost:5432/personal_super_app
```

Without Docker (Supabase / Neon / local Postgres), create a database and apply the schema:

```bash
psql "$DATABASE_URL" -f database/schema.sql
```

### 2. Backend

```bash
cd backend
cp .env.example .env   # then set DATABASE_URL + JWT_SECRET (+ CRON_SECRET)
npm install
npm run dev            # http://localhost:3000
```

- `npm run seed` fills the demo account with sample data for all 10 modules
  (login `demo@example.com` / `demo-password-123`; override with `SEED_EMAIL` /
  `SEED_PASSWORD`, re-seed with `SEED_FORCE=1`).
- Admin console at `http://localhost:3000/admin` — promote yourself via
  `POST /api/admin/bootstrap` while no admin exists yet.
- `next build` inlines env values into the Edge middleware, so make sure `.env`
  exists before a production build.

### 3. Mobile Apps

```bash
cd mobile
flutter pub get
flutter run -d chrome      # web (uses http://localhost:3000/api by default)
flutter run -d windows     # desktop
flutter run                # Android / iOS device or emulator
```

Point the app at another API:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:3000/api     # Android emulator
flutter run --dart-define=API_URL=https://your-api.vercel.app/api
```

## API Endpoints

| Endpoint | Method | Description |
| ---------- | -------- | ------------- |
| `/api/auth` | POST | Login / Register |
| `/api/dashboard` | GET | Aggregated dashboard data |
| `/api/finance/transactions` | GET/POST | List / Create transactions |
| `/api/journal` | GET/POST | Journal entries |
| `/api/bugs` | GET/POST | Bug entries |
| `/api/jobs` | GET/POST | Job applications |
| `/api/jobs/websites` | GET/POST/PUT/DELETE | Job source websites |
| `/api/projects` | GET/POST | Projects |
| `/api/habits` | GET/POST | Habits & logs |
| `/api/subscriptions` | GET/POST | Subscriptions |
| `/api/inventory` | GET/POST | Inventory items |
| `/api/bookmarks` | GET/POST | Bookmarks |

### API Conventions

All endpoints follow the same shape — clients must match it exactly:

- **Update / delete** take the id as a query parameter: `PUT /api/<module>?id=<uuid>`,
  `DELETE /api/<module>?id=<uuid>`.
- **Child resources** use the parent id as a query parameter on the collection
  route: `GET /api/projects/tasks?projectId=<uuid>`, and the same id goes in the
  request body when creating: `POST /api/projects/tasks` with `{ "projectId": "<uuid>" }`.
- **Pagination** is opt-in: `?page=1&pageSize=20` returns
  `{ data, total, page, pageSize, totalPages }`. Without `page`, the endpoint
  returns the plain array.
- **Auth**: every request except `/api/auth/*` needs `Authorization: Bearer <accessToken>`.
  Tokens are verified in `src/middleware.ts`, which runs on the Edge runtime and
  therefore uses `lib/jwt-edge.ts` (WebCrypto) instead of `jsonwebtoken`.
- Optional fields accept `null` (to clear a value) as well as being omitted.
- **Dates** are plain `YYYY-MM-DD` strings. "Today", the current month and the
  90-day habit window are resolved in the user's `timezone` (`Asia/Jakarta` by
  default) via `lib/user-time.ts`, not on the server clock — see
  `GET`/`PUT /api/profile` where the timezone is validated as an IANA name.

## Deployment

### Backend to Vercel

```bash
cd backend
vercel --prod
```

### Environment Variables (Vercel)

- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Random secret for token signing
- `CRON_SECRET` - Secret for the scheduled cron endpoint

## Features

- ✅ JWT Authentication with **refresh token rotation** (15m access + 30d refresh, revocable)
- ✅ Rate limiting on `/api/auth` (brute-force protection)
- ✅ User-scoped CRUD security (IDOR protection on all endpoints)
- ✅ Profile & change password endpoints
- ✅ **Forgot / reset password** flow
- ✅ **Secure token storage** (flutter_secure_storage)
- ✅ Data export (JSON/CSV) via `/api/export`
- ✅ CORS support for Flutter web
- ✅ 401 auto-refresh + auto-logout on token expiry
- ✅ **Pagination** on list endpoints (`?page=1&pageSize=20`)
- ✅ **Admin bootstrap** endpoint (first user becomes admin)
- ✅ **Charts & visualizations** (spending pie chart, income/expense bar chart)
- ✅ **Recurring transaction automation** (rules + process due + **scheduled cron**)
- ✅ **CSV import** for bank statements
- ✅ **Investment price tracking** (Yahoo Finance refresh)
- ✅ **Job Tracker statistics** (response/interview/offer rate)
- ✅ **Budget utilization alerts** (warning/exceeded status)
- ✅ **Habit streaks & heatmap** (90-day view)
- ✅ **Custom accent color** (8 theme colors)
- ✅ **Multi-language** (English / Bahasa Indonesia)
- ✅ **PWA install** (web)
- ✅ **Search & filter** in Finance, Journal, Bookmarks
- ✅ **Swipe actions** (edit/delete) in Finance
- ✅ **Shimmer loading** states
- ✅ **Open links** (bookmarks, job postings)
- ✅ Dark mode support
- ✅ Biometric lock (Android/iOS)
- ✅ Dashboard with aggregated metrics
- ✅ Comprehensive database schema with indexes
- ✅ Modular architecture for easy extension
- ✅ Type-safe API with Zod validation + sanitized error responses
- ✅ Unit tests (backend: vitest, mobile: flutter_test)
- ✅ CI/CD with GitHub Actions

## Roadmap

- [ ] **Image upload to object storage** — inventory photos and avatars are
      currently embedded as base64 data URIs in `photoUrls` / `avatarUrl`, so
      list responses carry the full image payloads. Upload endpoints + Vercel
      Blob / S3 would fix this (`cached_network_image` is already a dependency).
- [ ] **Reminder notifications** — `flutter_local_notifications` and `timezone`
      are installed but unused; wire them to `habits.reminderTime`,
      `subscriptions.reminderDays` and `finance_recurring_rules.nextExecution`.
- [ ] **Offline-first sync** — `lib/data/local_db.dart` (sqflite) is not wired to
      any screen yet; the connectivity banner only reports state.
- [ ] Server-side search & pagination in the client (`?page=`/`?pageSize=` and a
      `q` filter) instead of loading full lists and filtering in memory.
- [ ] Home screen widget (needs Android platform)
- [ ] Push notifications for reminders (needs a push service, not just local
      notifications)

## Done

- [x] Photo capture for inventory items / avatar (stored as data URIs for now)
- [x] Calendar view for habits (`table_calendar`)
- [x] Offline detection banner (`connectivity_plus`)
- [x] Dates resolved in the user's timezone instead of the server's
- [x] Edge-compatible JWT verification + user-scoped child-resource writes

