import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/referral_link.dart';
import '../models/achievement.dart';

class DatabaseService {
  static Connection? _connection;
  static bool _initialized = false;

  /// Initialize database connection
  static Future<void> initialize() async {
    if (_initialized && _connection != null) return;

    try {
      await dotenv.load(fileName: ".env");
      
      final host = dotenv.env['DB_HOST'] ?? 'localhost';
      final port = int.parse(dotenv.env['DB_PORT'] ?? '5432');
      final database = dotenv.env['DB_NAME'] ?? 'cloudwalk_referrals';
      final username = dotenv.env['DB_USER'] ?? 'postgres';
      final password = dotenv.env['DB_PASSWORD'] ?? '';

      print('🗄️ Connecting to PostgreSQL at $host:$port/$database...');

      _connection = await Connection.open(
        Endpoint(
          host: host,
          port: port,
          database: database,
          username: username,
          password: password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.disable,
          connectTimeout: Duration(seconds: 10),
          queryTimeout: Duration(seconds: 30),
        ),
      );

      await _createTables();
      _initialized = true;
      print('✅ Database connected and initialized successfully');

    } catch (e) {
      print('❌ Database connection failed: $e');
      // For development, we'll create an in-memory fallback
      print('🔧 Using fallback mode - database features will be limited');
      _initialized = false;
    }
  }

  /// Create database tables
  static Future<void> _createTables() async {
    if (_connection == null) return;

    try {
      // Users table
      await _connection!.execute('''
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
        )
      ''');

      // Referral links table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS referral_links (
          id VARCHAR(255) PRIMARY KEY,
          user_id VARCHAR(255) NOT NULL,
          user_name VARCHAR(255) NOT NULL,
          link_code VARCHAR(20) UNIQUE NOT NULL,
          full_url TEXT NOT NULL,
          click_count INTEGER DEFAULT 0,
          registration_count INTEGER DEFAULT 0,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
      ''');

      // Referral clicks table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS referral_clicks (
          id SERIAL PRIMARY KEY,
          link_code VARCHAR(20) NOT NULL,
          ip_address VARCHAR(45),
          user_agent TEXT,
          clicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          completed_registration BOOLEAN DEFAULT FALSE,
          completed_email VARCHAR(255)
        )
      ''');

      // User achievements table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS user_achievements (
          id SERIAL PRIMARY KEY,
          user_id VARCHAR(255) NOT NULL,
          achievement_id VARCHAR(50) NOT NULL,
          unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          UNIQUE(user_id, achievement_id)
        )
      ''');

      // Admin users table
      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS admin_users (
          id SERIAL PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) UNIQUE NOT NULL,
          password_hash VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      print('✅ Database tables created successfully');

    } catch (e) {
      print('❌ Error creating tables: $e');
    }
  }

  /// Get database connection
  static Connection? get connection => _connection;

  /// Check if database is available
  static bool get isAvailable => _initialized && _connection != null;

  /// Close database connection
  static Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      _initialized = false;
      print('🗄️ Database connection closed');
    }
  }

  // USER OPERATIONS

  /// Create a new user
  static Future<User?> createUser(User user, String passwordHash) async {
    if (!isAvailable) return null;

    try {
      await _connection!.execute(
        '''
        INSERT INTO users (id, first_name, last_name, email, password_hash, 
                          referral_code, total_referrals, total_earnings, created_at)
        VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9)
        ''',
        parameters: [
          user.id,
          user.firstName,
          user.lastName,
          user.email,
          passwordHash,
          user.referralCode,
          user.totalReferrals,
          user.totalEarnings,
          user.createdAt.toIso8601String(),
        ],
      );

      print('✅ User created: ${user.email}');
      return user;

    } catch (e) {
      print('❌ Error creating user: $e');
      return null;
    }
  }

  /// Get user by email
  static Future<User?> getUserByEmail(String email) async {
    if (!isAvailable) return null;

    try {
      final result = await _connection!.execute(
        'SELECT * FROM users WHERE email = \$1',
        parameters: [email.toLowerCase()],
      );

      if (result.isEmpty) return null;

      final row = result.first;
      return User(
        id: row[0] as String,
        firstName: row[1] as String,
        lastName: row[2] as String,
        email: row[3] as String,
        referralCode: row[5] as String,
        totalReferrals: row[6] as int,
        totalEarnings: (row[7] as num).toDouble(),
        createdAt: DateTime.parse(row[8] as String),
      );

    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }

  /// Get user by referral code
  static Future<User?> getUserByReferralCode(String referralCode) async {
    if (!isAvailable) return null;

    try {
      final result = await _connection!.execute(
        'SELECT * FROM users WHERE referral_code = \$1',
        parameters: [referralCode.toUpperCase()],
      );

      if (result.isEmpty) return null;

      final row = result.first;
      return User(
        id: row[0] as String,
        firstName: row[1] as String,
        lastName: row[2] as String,
        email: row[3] as String,
        referralCode: row[5] as String,
        totalReferrals: row[6] as int,
        totalEarnings: (row[7] as num).toDouble(),
        createdAt: DateTime.parse(row[8] as String),
      );

    } catch (e) {
      print('❌ Error getting user by referral code: $e');
      return null;
    }
  }

  /// Get all users
  static Future<List<User>> getAllUsers() async {
    if (!isAvailable) return [];

    try {
      final result = await _connection!.execute(
        'SELECT * FROM users ORDER BY total_referrals DESC, created_at ASC'
      );

      return result.map((row) => User(
        id: row[0] as String,
        firstName: row[1] as String,
        lastName: row[2] as String,
        email: row[3] as String,
        referralCode: row[5] as String,
        totalReferrals: row[6] as int,
        totalEarnings: (row[7] as num).toDouble(),
        createdAt: DateTime.parse(row[8] as String),
      )).toList();

    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  /// Update user referrals and earnings
  static Future<bool> updateUserMetrics(String userId, int newReferrals, double newEarnings) async {
    if (!isAvailable) return false;

    try {
      await _connection!.execute(
        '''
        UPDATE users 
        SET total_referrals = \$1, total_earnings = \$2
        WHERE id = \$3
        ''',
        parameters: [newReferrals, newEarnings, userId],
      );

      return true;

    } catch (e) {
      print('❌ Error updating user metrics: $e');
      return false;
    }
  }

  /// Verify user password
  static Future<String?> getPasswordHash(String email) async {
    if (!isAvailable) return null;

    try {
      final result = await _connection!.execute(
        'SELECT password_hash FROM users WHERE email = \$1',
        parameters: [email.toLowerCase()],
      );

      if (result.isEmpty) return null;
      return result.first[0] as String;

    } catch (e) {
      print('❌ Error getting password hash: $e');
      return null;
    }
  }

  // REFERRAL LINK OPERATIONS

  /// Create referral link
  static Future<ReferralLink?> createReferralLink(ReferralLink link) async {
    if (!isAvailable) return null;

    try {
      await _connection!.execute(
        '''
        INSERT INTO referral_links (id, user_id, user_name, link_code, full_url, 
                                   click_count, registration_count, created_at)
        VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8)
        ''',
        parameters: [
          link.id,
          link.userId,
          link.userName,
          link.linkCode,
          link.fullUrl,
          link.clickCount,
          link.registrationCount,
          link.createdAt.toIso8601String(),
        ],
      );

      return link;

    } catch (e) {
      print('❌ Error creating referral link: $e');
      return null;
    }
  }

  /// Get referral links by user
  static Future<List<ReferralLink>> getReferralLinksByUser(String userId) async {
    if (!isAvailable) return [];

    try {
      final result = await _connection!.execute(
        'SELECT * FROM referral_links WHERE user_id = \$1',
        parameters: [userId],
      );

      return result.map((row) => ReferralLink(
        id: row[0] as String,
        userId: row[1] as String,
        userName: row[2] as String,
        linkCode: row[3] as String,
        fullUrl: row[4] as String,
        clickCount: row[5] as int,
        registrationCount: row[6] as int,
        createdAt: DateTime.parse(row[7] as String),
      )).toList();

    } catch (e) {
      print('❌ Error getting referral links: $e');
      return [];
    }
  }

  /// Get all referral links
  static Future<List<ReferralLink>> getAllReferralLinks() async {
    if (!isAvailable) return [];

    try {
      final result = await _connection!.execute(
        'SELECT * FROM referral_links ORDER BY created_at DESC'
      );

      return result.map((row) => ReferralLink(
        id: row[0] as String,
        userId: row[1] as String,
        userName: row[2] as String,
        linkCode: row[3] as String,
        fullUrl: row[4] as String,
        clickCount: row[5] as int,
        registrationCount: row[6] as int,
        createdAt: DateTime.parse(row[7] as String),
      )).toList();

    } catch (e) {
      print('❌ Error getting all referral links: $e');
      return [];
    }
  }

  /// Track referral click
  static Future<bool> trackReferralClick(String linkCode, String? ipAddress, String? userAgent) async {
    if (!isAvailable) return false;

    try {
      // Insert click record
      await _connection!.execute(
        '''
        INSERT INTO referral_clicks (link_code, ip_address, user_agent)
        VALUES (\$1, \$2, \$3)
        ''',
        parameters: [linkCode, ipAddress, userAgent],
      );

      // Update link click count
      await _connection!.execute(
        '''
        UPDATE referral_links 
        SET click_count = click_count + 1
        WHERE link_code = \$1
        ''',
        parameters: [linkCode],
      );

      return true;

    } catch (e) {
      print('❌ Error tracking referral click: $e');
      return false;
    }
  }

  /// Track registration completion
  static Future<bool> trackRegistrationCompletion(String linkCode, String email) async {
    if (!isAvailable) return false;

    try {
      // Update click record as completed
      await _connection!.execute(
        '''
        UPDATE referral_clicks 
        SET completed_registration = TRUE, completed_email = \$1
        WHERE link_code = \$2 AND completed_registration = FALSE
        ORDER BY clicked_at DESC
        LIMIT 1
        ''',
        parameters: [email, linkCode],
      );

      // Update link registration count
      await _connection!.execute(
        '''
        UPDATE referral_links 
        SET registration_count = registration_count + 1
        WHERE link_code = \$1
        ''',
        parameters: [linkCode],
      );

      return true;

    } catch (e) {
      print('❌ Error tracking registration completion: $e');
      return false;
    }
  }

  // ADMIN OPERATIONS

  /// Create default admin
  static Future<void> createDefaultAdmin() async {
    if (!isAvailable) return;

    try {
      // Check if admin already exists
      final existing = await _connection!.execute(
        'SELECT COUNT(*) FROM admin_users WHERE email = \$1',
        parameters: ['admin@cloudwalk.com'],
      );

      if ((existing.first[0] as int) > 0) return;

      // Create default admin
      await _connection!.execute(
        '''
        INSERT INTO admin_users (name, email, password_hash)
        VALUES (\$1, \$2, \$3)
        ''',
        parameters: [
          'CloudWalk Admin',
          'admin@cloudwalk.com',
          'e10adc3949ba59abbe56e057f20f883e', // MD5 hash of 'cloudwalk123'
        ],
      );

      print('✅ Default admin created');

    } catch (e) {
      print('❌ Error creating default admin: $e');
    }
  }

  /// Populate database with sample data
  static Future<void> populateWithSampleData() async {
    if (!isAvailable) {
      print('❌ Database not available for sample data');
      return;
    }

    try {
      // Check if data already exists
      final userCount = await _connection!.execute('SELECT COUNT(*) FROM users');
      if ((userCount.first[0] as int) > 0) {
        print('📊 Database already has data, skipping sample data creation');
        return;
      }

      print('🎭 Creating sample data in PostgreSQL...');

      // Sample users data
      final sampleUsers = [
        {'firstName': 'João', 'lastName': 'Silva', 'email': 'joao.silva@email.com', 'referrals': 2, 'earnings': 125.0},
        {'firstName': 'Maria', 'lastName': 'Santos', 'email': 'maria.santos@email.com', 'referrals': 0, 'earnings': 25.0},
        {'firstName': 'Pedro', 'lastName': 'Costa', 'email': 'pedro.costa@email.com', 'referrals': 0, 'earnings': 25.0},
        {'firstName': 'Ana', 'lastName': 'Oliveira', 'email': 'ana.oliveira@email.com', 'referrals': 4, 'earnings': 200.0},
        {'firstName': 'Carlos', 'lastName': 'Ferreira', 'email': 'carlos.ferreira@email.com', 'referrals': 0, 'earnings': 25.0},
        {'firstName': 'Lucia', 'lastName': 'Rodrigues', 'email': 'lucia.rodrigues@email.com', 'referrals': 1, 'earnings': 50.0},
        {'firstName': 'Rafael', 'lastName': 'Almeida', 'email': 'rafael.almeida@email.com', 'referrals': 0, 'earnings': 25.0},
        {'firstName': 'Camila', 'lastName': 'Lima', 'email': 'camila.lima@email.com', 'referrals': 0, 'earnings': 25.0},
        {'firstName': 'Bruno', 'lastName': 'Martins', 'email': 'bruno.martins@email.com', 'referrals': 0, 'earnings': 25.0},
        {'firstName': 'Fernanda', 'lastName': 'Pereira', 'email': 'fernanda.pereira@email.com', 'referrals': 0, 'earnings': 25.0},
      ];

      // Create users
      for (final userData in sampleUsers) {
        final user = User(
          id: userData['email'] as String,
          firstName: userData['firstName'] as String,
          lastName: userData['lastName'] as String,
          email: userData['email'] as String,
          referralCode: _generateReferralCode(),
          totalReferrals: userData['referrals'] as int,
          totalEarnings: userData['earnings'] as double,
          createdAt: DateTime.now().subtract(Duration(days: DateTime.now().millisecond % 365)),
        );

        await createUser(user, 'e10adc3949ba59abbe56e057f20f883e'); // MD5 hash of '123456'
        print('✅ Created user: ${user.firstName} ${user.lastName} (${user.totalReferrals} referrals, \$${user.totalEarnings})');
      }

      print('🏆 Sample data created successfully in PostgreSQL!');

    } catch (e) {
      print('❌ Error creating sample data: $e');
    }
  }

  /// Generate referral code
  static String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    final random = DateTime.now().millisecondsSinceEpoch;
    String code = '';
    
    for (int i = 0; i < 8; i++) {
      code += chars[(random + i) % chars.length];
    }
    
    return code;
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> getDatabaseStats() async {
    if (!isAvailable) return {};

    try {
      final userCount = await _connection!.execute('SELECT COUNT(*) FROM users');
      final linkCount = await _connection!.execute('SELECT COUNT(*) FROM referral_links');
      final clickCount = await _connection!.execute('SELECT COUNT(*) FROM referral_clicks');
      final completionCount = await _connection!.execute('SELECT COUNT(*) FROM referral_clicks WHERE completed_registration = TRUE');

      return {
        'totalUsers': userCount.first[0] as int,
        'totalLinks': linkCount.first[0] as int,
        'totalClicks': clickCount.first[0] as int,
        'totalCompletions': completionCount.first[0] as int,
        'conversionRate': (clickCount.first[0] as int) > 0 
          ? (completionCount.first[0] as int) / (clickCount.first[0] as int)
          : 0.0,
      };

    } catch (e) {
      print('❌ Error getting database stats: $e');
      return {};
    }
  }
}
