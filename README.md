# BHAGWA BACKEND — PRODUCTION-READY SUPABASE BACKEND

Production-grade Supabase & PostgreSQL backend architecture for the **Bhagwa Devotional Application** (`bhagwa`) and **Bhagwa Admin Dashboard** (`bhagwa-admin`).

---

## 🏛 Architecture Overview

```text
                    SUPABASE
                       │
          ┌────────────┼─────────────┐
          │            │             │
       Database      Auth        Functions
          │
          │
     ┌────┴────┐
     │         │
 Flutter     Admin
   App      Dashboard
     │         │
     └────┬────┘
          │
      Cloudflare R2
          │
     Media Storage
```

- **Source of Truth for Application Data**: Supabase PostgreSQL
- **Source of Truth for Large Media (4K Wallpapers, MP3 Audio, Videos)**: Cloudflare R2
- **Authorization & Security**: Supabase Auth + Database Row Level Security (RLS)

---

## 📁 Directory Structure

```text
bhagwa-backend/
├── supabase/
│   ├── config.toml                     # Supabase project configuration
│   ├── seed.sql                         # Initial seed data (Deities, Categories, Sample Posts, Settings)
│   ├── migrations/                      # Database migrations
│   │   ├── 20260816000001_initial_schema.sql
│   │   ├── 20260816000002_rls_policies.sql
│   │   └── 20260816000003_functions_and_rpcs.sql
│   └── functions/                       # Edge Functions
│       ├── admin/
│       ├── media/                       # R2 signing operations
│       ├── feed/
│       ├── notifications/
│       └── payments/
├── src/
│   ├── types/                           # Generated TypeScript database types
│   │   └── database.types.ts
│   ├── services/                        # Storage & Auth service abstractions
│   ├── repositories/                    # Data repositories
│   └── utils/
├── .env.example                         # Environment variable template
├── package.json
└── README.md
```

---

## ⚙️ Local Development Commands

1. **Install Supabase CLI Dependencies**:
   ```bash
   cd ~/Desktop/bhagwa-backend
   npm install
   ```

2. **Start Local Supabase Emulator**:
   ```bash
   npx supabase start
   ```

3. **Reset Database & Apply Seed**:
   ```bash
   npx supabase db reset
   ```

4. **Generate TypeScript Types**:
   ```bash
   npm run supabase:gen:types
   ```
