# 🗄️ CloudWalk PostgreSQL Database Setup

## 🚀 Quick Start Options

### Option 1: Docker (Recommended - Easiest)

1. **Install Docker** (if not installed):
   ```bash
   sudo apt update
   sudo apt install docker.io docker-compose
   sudo usermod -aG docker $USER
   # Logout and login again
   ```

2. **Start Database**:
   ```bash
   ./start_database.sh
   ```

3. **Test Mobile App**:
   ```bash
   ./test_mobile_db.sh
   ```

### Option 2: Manual PostgreSQL Installation

1. **Install PostgreSQL**:
   ```bash
   sudo apt update
   sudo apt install postgresql postgresql-contrib
   sudo systemctl start postgresql
   sudo systemctl enable postgresql
   ```

2. **Create Database and User**:
   ```bash
   sudo -u postgres psql
   ```
   
   In PostgreSQL shell:
   ```sql
   CREATE DATABASE cloudwalk_referrals;
   CREATE USER cloudwalk WITH PASSWORD 'cloudwalk123';
   GRANT ALL PRIVILEGES ON DATABASE cloudwalk_referrals TO cloudwalk;
   \q
   ```

3. **Run Initialization Script**:
   ```bash
   psql -h localhost -U cloudwalk -d cloudwalk_referrals -f init.sql
   ```

### Option 3: Backend API (For Web Support)

1. **Install Dart SDK** (if not installed):
   ```bash
   sudo apt update
   sudo apt install dart
   ```

2. **Setup Backend**:
   ```bash
   cd backend
   dart pub get
   dart run server.dart
   ```

3. **Test API**:
   ```bash
   curl http://localhost:8080/health
   ```

## 🔧 Configuration

### Database Configuration (.env)
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=cloudwalk_referrals
DB_USER=cloudwalk
DB_PASSWORD=cloudwalk123
```

### OpenAI Configuration (.env)
```env
OPENAI_API_KEY=your-openai-api-key-here
OPENAI_ORGANIZATION_ID=your-org-id-here
```

## 📱 Platform Support

| Platform | PostgreSQL Direct | Backend API | Mock Data |
|----------|-------------------|-------------|-----------|
| Android  | ✅ Works         | ✅ Works   | ✅ Works |
| iOS      | ✅ Works         | ✅ Works   | ✅ Works |
| Web      | ❌ Not supported | ✅ Works   | ✅ Works |

## 🧪 Testing

### Test Database Connection
```bash
# Check if database is running
docker ps | grep cloudwalk_postgres

# Connect manually to database
psql -h localhost -U cloudwalk -d cloudwalk_referrals

# View tables
\dt
```

### Test Mobile App with Database
```bash
# Start database first
./start_database.sh

# Run on Android
flutter run -d android -t lib/main_auth.dart

# Run on iOS  
flutter run -d ios -t lib/main_auth.dart
```

### Test Web App with API
```bash
# Terminal 1: Start database
./start_database.sh

# Terminal 2: Start API server
cd backend
dart run server.dart

# Terminal 3: Run web app
flutter run -d chrome -t lib/main_auth.dart
```

## 📊 Database Schema

### Tables Created
- **users**: User accounts and referral data
- **referral_links**: Generated referral links  
- **referral_clicks**: Click tracking data
- **user_achievements**: Achievement progress
- **admin_users**: Admin account management

### Sample Data Population
The app will automatically create sample data when you:
1. Open the "PostgreSQL Database Setup" screen
2. Click "Create Sample Data"

## 🛠️ Troubleshooting

### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# View database logs
docker-compose logs postgres

# Restart database
docker-compose restart postgres
```

### Permission Issues
```bash
# Fix Docker permissions
sudo usermod -aG docker $USER
# Logout and login again

# Fix database permissions
sudo -u postgres psql
GRANT ALL PRIVILEGES ON DATABASE cloudwalk_referrals TO cloudwalk;
```

### Port Conflicts
If port 5432 is in use:
1. Edit `docker-compose.yml`
2. Change `"5432:5432"` to `"5433:5432"`  
3. Update `.env`: `DB_PORT=5433`

## 📈 Production Considerations

### Security
- Change default passwords in production
- Use environment-specific `.env` files
- Enable SSL/TLS for database connections
- Implement proper authentication tokens

### Performance
- Add database indexes (already included in `init.sql`)
- Configure connection pooling
- Monitor database performance
- Implement caching layer

### Deployment
- Use managed PostgreSQL (AWS RDS, Google Cloud SQL)
- Deploy backend API to cloud (Google Cloud Run, AWS Lambda)
- Configure load balancing
- Set up database backups

## 🔄 Migration from Mock Data

The app automatically detects database availability:
- **Database available**: Uses PostgreSQL
- **Database unavailable**: Falls back to mock data

No code changes needed - it works seamlessly!

## 📞 Support

If you encounter issues:
1. Check the logs: `docker-compose logs postgres`
2. Verify `.env` configuration
3. Test database connection manually
4. Check firewall/network settings

## 🎯 Next Steps

1. **Start with Docker** (easiest option)
2. **Test on mobile** to see PostgreSQL in action
3. **Try the backend API** for web support  
4. **Add your own data** and features
5. **Deploy to production** when ready


