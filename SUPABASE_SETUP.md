# 🌐 Supabase Setup (Cloud Database - No Installation Needed)

## Why Supabase?
- ✅ **No installation required**
- ✅ **Works with Web, Android, iOS**
- ✅ **Free tier available**
- ✅ **Built-in authentication**
- ✅ **Automatic API generation**

## Setup Steps

### 1. Create Supabase Account
1. Go to [supabase.com](https://supabase.com)
2. Sign up for free account
3. Create a new project

### 2. Get Your Credentials
1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy:
   - **Project URL** (looks like: `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

### 3. Update .env File
```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 4. Create Database Tables
In Supabase dashboard → **SQL Editor**, run this:

```sql
-- Users table
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    referral_code VARCHAR(20) UNIQUE NOT NULL,
    total_referrals INTEGER DEFAULT 0,
    total_earnings DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Referral links table
CREATE TABLE IF NOT EXISTS referral_links (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    link_code VARCHAR(20) UNIQUE NOT NULL,
    full_url TEXT NOT NULL,
    click_count INTEGER DEFAULT 0,
    registration_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Referral clicks table
CREATE TABLE IF NOT EXISTS referral_clicks (
    id SERIAL PRIMARY KEY,
    link_code VARCHAR(20) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    clicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_registration BOOLEAN DEFAULT FALSE,
    completed_email VARCHAR(255)
);

-- Admin users table
CREATE TABLE IF NOT EXISTS admin_users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default admin
INSERT INTO admin_users (name, email, password_hash) 
VALUES ('CloudWalk Admin', 'admin@cloudwalk.com', 'e10adc3949ba59abbe56e057f20f883e')
ON CONFLICT (email) DO NOTHING;
```

### 5. Run Your App
```bash
flutter run -d chrome -t lib/main_auth.dart   # Works on web!
flutter run -d android -t lib/main_auth.dart  # Works on mobile!
```

## Advantages
- ✅ No PostgreSQL installation
- ✅ Works on all platforms
- ✅ Automatic scaling
- ✅ Built-in admin panel
- ✅ Real-time features
- ✅ Free tier: 50,000 monthly active users


