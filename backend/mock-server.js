const express = require('express');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const app = express();
const port = process.env.PORT || 3002;

// Middleware
app.use(cors({
  origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:*', '*'],
  credentials: true
}));
app.use(express.json());

// Mock Database (In-memory storage)
let users = [];
let referralLinks = [];
let referralClicks = [];

// Utility function to generate referral code
function generateReferralCode(length = 8) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// JWT middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, 'your-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
};

// Routes

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Referral API is running (Mock Mode)' });
});

// User registration
app.post('/api/register', async (req, res) => {
  try {
    const { firstName, lastName, email, password } = req.body;

    // Check if user already exists
    const existingUser = users.find(user => user.email === email);
    if (existingUser) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Generate unique referral code
    let referralCode;
    let isUnique = false;
    while (!isUnique) {
      referralCode = generateReferralCode();
      isUnique = !users.find(user => user.referralCode === referralCode);
    }

    // Create user
    const userId = uuidv4();
    const newUser = {
      id: userId,
      first_name: firstName,
      last_name: lastName,
      email: email,
      password_hash: passwordHash,
      referral_code: referralCode,
      total_referrals: 0,
      total_earnings: 0.00,
      created_at: new Date()
    };

    users.push(newUser);

    // Generate JWT token
    const token = jwt.sign(
      { userId: newUser.id, email: newUser.email },
      'your-secret-key',
      { expiresIn: '24h' }
    );

    // Remove password hash from response
    const userResponse = { ...newUser };
    delete userResponse.password_hash;

    res.status(201).json({
      message: 'User created successfully',
      user: userResponse,
      token
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// User login
app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = users.find(u => u.email === email);
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      'your-secret-key',
      { expiresIn: '24h' }
    );

    // Remove password hash from response
    const userResponse = { ...user };
    delete userResponse.password_hash;

    res.json({
      message: 'Login successful',
      user: userResponse,
      token
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user profile
app.get('/api/profile', authenticateToken, (req, res) => {
  try {
    const user = users.find(u => u.id === req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const userResponse = { ...user };
    delete userResponse.password_hash;

    res.json({ user: userResponse });
  } catch (error) {
    console.error('Profile error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user referrals
app.get('/api/referrals', authenticateToken, (req, res) => {
  try {
    const userReferrals = referralLinks.filter(link => link.user_id === req.user.userId);
    res.json({ referrals: userReferrals });
  } catch (error) {
    console.error('Referrals error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create referral link
app.post('/api/referrals', authenticateToken, (req, res) => {
  try {
    const { userName } = req.body;

    // Get user info
    const user = users.find(u => u.id === req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const linkCode = `${user.referral_code}-${Date.now().toString(36)}`;
    const fullUrl = `http://localhost:8080/register?ref=${linkCode}`;

    const newReferral = {
      id: uuidv4(),
      user_id: req.user.userId,
      user_name: userName || `${user.first_name} ${user.last_name}`,
      link_code: linkCode,
      full_url: fullUrl,
      click_count: 0,
      registration_count: 0,
      created_at: new Date()
    };

    referralLinks.push(newReferral);

    res.status(201).json({
      message: 'Referral link created successfully',
      referral: newReferral
    });
  } catch (error) {
    console.error('Create referral error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get analytics data
app.get('/api/analytics', authenticateToken, (req, res) => {
  try {
    const user = users.find(u => u.id === req.user.userId);
    const userReferrals = referralLinks.filter(link => link.user_id === req.user.userId);
    const userClicks = referralClicks.filter(click => 
      userReferrals.some(link => link.link_code === click.link_code)
    );

    // Generate mock analytics data
    const clickStats = [];
    for (let i = 0; i < 7; i++) {
      const date = new Date();
      date.setDate(date.getDate() - i);
      clickStats.push({
        date: date.toISOString().split('T')[0],
        clicks: Math.floor(Math.random() * 20),
        conversions: Math.floor(Math.random() * 5)
      });
    }

    res.json({
      userStats: {
        total_referrals: user.total_referrals,
        total_earnings: user.total_earnings
      },
      clickStats: clickStats.reverse(),
      topLinks: userReferrals.slice(0, 5)
    });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Track referral click
app.post('/api/track-click/:linkCode', (req, res) => {
  try {
    const { linkCode } = req.params;
    const { ipAddress, userAgent } = req.body;

    // Record the click
    referralClicks.push({
      id: uuidv4(),
      link_code: linkCode,
      ip_address: ipAddress,
      user_agent: userAgent,
      clicked_at: new Date(),
      completed_registration: false
    });

    // Update click count
    const link = referralLinks.find(l => l.link_code === linkCode);
    if (link) {
      link.click_count += 1;
    }

    res.json({ message: 'Click tracked successfully' });
  } catch (error) {
    console.error('Track click error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Demo: Create sample data
app.post('/api/demo/seed', (req, res) => {
  try {
    // Clear existing data
    users.length = 0;
    referralLinks.length = 0;
    referralClicks.length = 0;

    // Create demo user
    const demoUser = {
      id: 'demo-user-123',
      first_name: 'John',
      last_name: 'Doe',
      email: 'demo@cloudwalk.com',
      password_hash: '$2b$10$demo.hash.for.testing', // password: 'demo123'
      referral_code: 'DEMO123',
      total_referrals: 5,
      total_earnings: 125.50,
      created_at: new Date()
    };

    users.push(demoUser);

    // Create demo referral links
    for (let i = 1; i <= 3; i++) {
      referralLinks.push({
        id: `demo-link-${i}`,
        user_id: demoUser.id,
        user_name: `Friend ${i}`,
        link_code: `DEMO123-${i}`,
        full_url: `http://localhost:8080/register?ref=DEMO123-${i}`,
        click_count: Math.floor(Math.random() * 50),
        registration_count: Math.floor(Math.random() * 10),
        created_at: new Date()
      });
    }

    res.json({ 
      message: 'Demo data created successfully',
      credentials: {
        email: 'demo@cloudwalk.com',
        password: 'demo123'
      }
    });
  } catch (error) {
    console.error('Demo seed error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Start server
app.listen(port, () => {
  console.log(`🚀 Referral API server running on port ${port} (Mock Mode)`);
  console.log(`📊 Visit http://localhost:${port}/health to check status`);
  console.log(`🎯 Create demo data: POST http://localhost:${port}/api/demo/seed`);
});
