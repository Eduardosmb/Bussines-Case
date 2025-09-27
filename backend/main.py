from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, timedelta
import os
from openai import OpenAI
from passlib.context import CryptContext
import dotenv
from jose import JWTError, jwt
import uuid
import uvicorn
import hashlib

# Load environment variables
dotenv.load_dotenv()

# Initialize OpenAI client
openai_client = None
openai_api_key = os.getenv("OPENAI_API_KEY")
if openai_api_key:
    openai_client = OpenAI(api_key=openai_api_key)

# FastAPI app initialization
app = FastAPI(
    title="CloudWalk Referral API",
    description="Advanced referral program API built with FastAPI",
    version="1.0.0",
    docs_url="/docs",  # Automatic API documentation at /docs
    redoc_url="/redoc"  # Alternative docs at /redoc
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security configuration
SECRET_KEY = "cloudwalk-super-secret-key-change-in-production"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 24 hours

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto", bcrypt__rounds=12)
security = HTTPBearer()

# In-memory database (mock data)
users_db = {}
referrals_db = {}
clicks_db = []
achievements_db = {}

# Pydantic models
class UserRegister(BaseModel):
    firstName: str
    lastName: str
    email: EmailStr
    password: str
    referralCode: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class ChatRequest(BaseModel):
    message: str

class Achievement(BaseModel):
    id: str
    title: str
    description: str
    icon: str
    target_value: int
    reward_amount: float
    category: str  # 'referrals', 'earnings', 'social'

# Password utilities (simplified for demo)
def verify_password(plain_password, hashed_password):
    return hashlib.sha256(plain_password.encode()).hexdigest() == hashed_password

def get_password_hash(password):
    return hashlib.sha256(password.encode()).hexdigest()

# JWT utilities
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")
    
    user = users_db.get(user_id)
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user

# Initialize achievements
def initialize_achievements():
    achievements = [
        {
            "id": "first_referral",
            "title": "First Referral",
            "description": "Make your first successful referral",
            "icon": "🎯",
            "target_value": 1,
            "reward_amount": 10.0,
            "category": "referrals"
        },
        {
            "id": "five_referrals",
            "title": "Networker",
            "description": "Achieve 5 successful referrals",
            "icon": "🚀",
            "target_value": 5,
            "reward_amount": 25.0,
            "category": "referrals"
        },
        {
            "id": "ten_referrals",
            "title": "Influencer",
            "description": "Reach 10 successful referrals",
            "icon": "⭐",
            "target_value": 10,
            "reward_amount": 50.0,
            "category": "referrals"
        },
        {
            "id": "twenty_referrals",
            "title": "Super Star",
            "description": "Amazing! 20 successful referrals",
            "icon": "🏆",
            "target_value": 20,
            "reward_amount": 100.0,
            "category": "referrals"
        },
        {
            "id": "hundred_earnings",
            "title": "Earner",
            "description": "Earn your first $100",
            "icon": "💰",
            "target_value": 100,
            "reward_amount": 20.0,
            "category": "earnings"
        },
        {
            "id": "five_hundred_earnings",
            "title": "Money Maker",
            "description": "Earn $500 in total",
            "icon": "💎",
            "target_value": 500,
            "reward_amount": 50.0,
            "category": "earnings"
        }
    ]
    
    for achievement in achievements:
        achievements_db[achievement["id"]] = achievement

# Initialize achievements on startup
initialize_achievements()

# Utility functions
def generate_referral_code():
    """Generate a 6-character referral code"""
    import random
    import string
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def check_achievements(user_id: str):
    """Check and unlock achievements for a user"""
    user = users_db.get(user_id)
    if not user:
        return []
    
    newly_unlocked = []
    user_achievements = user.get("achievements", [])
    
    for achievement_id, achievement in achievements_db.items():
        # Skip if already unlocked
        if achievement_id in user_achievements:
            continue
            
        # Check achievement criteria
        if achievement["category"] == "referrals":
            if user.get("total_referrals", 0) >= achievement["target_value"]:
                user_achievements.append(achievement_id)
                user["total_earnings"] += achievement["reward_amount"]
                newly_unlocked.append(achievement)
                
        elif achievement["category"] == "earnings":
            if user.get("total_earnings", 0) >= achievement["target_value"]:
                user_achievements.append(achievement_id)
                user["total_earnings"] += achievement["reward_amount"]
                newly_unlocked.append(achievement)
    
    user["achievements"] = user_achievements
    return newly_unlocked

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "timestamp": datetime.utcnow()}

# Authentication endpoints
@app.post("/api/register", response_model=dict)
async def register_user(user: UserRegister):
    # Check if user already exists
    if any(u["email"] == user.email for u in users_db.values()):
        raise HTTPException(status_code=400, detail="Email already registered")
    
    # Generate user ID and referral code
    user_id = str(uuid.uuid4())
    referral_code = generate_referral_code()
    
    # Hash password
    hashed_password = get_password_hash(user.password)
    
    # Create user
    new_user = {
        "id": user_id,
        "first_name": user.firstName,
        "last_name": user.lastName,
        "email": user.email,
        "password": hashed_password,
        "referral_code": referral_code,
        "total_referrals": 0,
        "total_earnings": 0.0,
        "achievements": [],
        "created_at": datetime.utcnow().isoformat()
    }
    
    # Handle referral code if provided
    referral_bonus = None
    if user.referralCode:
        # Find the referrer
        referrer = None
        for u in users_db.values():
            if u.get("referral_code") == user.referralCode:
                referrer = u
                break
                
        if referrer:
            # Give bonus to new user ($25)
            new_user["total_earnings"] = 25.0
            # Give bonus to referrer ($50)
            referrer["total_earnings"] += 50.0
            referrer["total_referrals"] += 1
            
            # Check achievements for referrer
            check_achievements(referrer["id"])
            
            referral_bonus = {
                "new_user_bonus": 25.0,
                "referrer_bonus": 50.0,
                "referrer_email": referrer["email"]
            }
            
            print(f"✅ Referral bonus: New user gets $25, Referrer {referrer['email']} gets $50")
    
    # Save user
    users_db[user_id] = new_user
    
    # Check achievements for new user
    check_achievements(user_id)
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user_id}, expires_delta=access_token_expires
    )
    
    response = {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user_id,
            "first_name": user.firstName,
            "last_name": user.lastName,
            "email": user.email,
            "referral_code": referral_code,
            "total_referrals": new_user["total_referrals"],
            "total_earnings": new_user["total_earnings"],
            "created_at": new_user["created_at"]
        }
    }
    
    if referral_bonus:
        response["referral_bonus"] = referral_bonus
        response["referral_message"] = f"🎉 Welcome! You earned $25 and your referrer earned $50!"
    
    return response

@app.post("/api/login", response_model=dict)
async def login_user(user: UserLogin):
    # Find user by email
    found_user = None
    for u in users_db.values():
        if u["email"] == user.email:
            found_user = u
            break
    
    if not found_user or not verify_password(user.password, found_user["password"]):
        raise HTTPException(status_code=401, detail="Incorrect email or password")
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": found_user["id"]}, expires_delta=access_token_expires
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": found_user["id"],
            "first_name": found_user["first_name"],
            "last_name": found_user["last_name"],
            "email": found_user["email"],
            "referral_code": found_user["referral_code"],
            "total_referrals": found_user["total_referrals"],
            "total_earnings": found_user["total_earnings"],
            "created_at": found_user["created_at"]
        }
    }

# Demo data endpoint
@app.post("/api/demo-data")
async def create_demo_data():
    """Create demo users and data for testing"""
    import random
    
    # Clear existing data
    users_db.clear()
    referrals_db.clear()
    
    # Create demo users
    demo_users = [
        {
            "firstName": "Maria",
            "lastName": "Silva",
            "email": "maria@cloudwalk.com",
            "password": "senha123",
            "total_referrals": 8,
            "total_earnings": 425.0
        },
        {
            "firstName": "João",
            "lastName": "Santos",
            "email": "joao@cloudwalk.com",
            "password": "senha123",
            "total_referrals": 3,
            "total_earnings": 175.0
        },
        {
            "firstName": "Ana",
            "lastName": "Costa",
            "email": "ana@cloudwalk.com",
            "password": "senha123",
            "total_referrals": 12,
            "total_earnings": 650.0
        }
    ]
    
    for demo_data in demo_users:
        user_id = str(uuid.uuid4())
        referral_code = generate_referral_code()
        hashed_password = get_password_hash(demo_data["password"])
        
        user = {
            "id": user_id,
            "first_name": demo_data["firstName"],
            "last_name": demo_data["lastName"],
            "email": demo_data["email"],
            "password": hashed_password,
            "referral_code": referral_code,
            "total_referrals": demo_data["total_referrals"],
            "total_earnings": demo_data["total_earnings"],
            "achievements": [],
            "created_at": datetime.utcnow().isoformat()
        }
        
        # Check achievements
        check_achievements(user_id)
        users_db[user_id] = user
    
    return {
        "message": "Demo data created successfully",
        "users_created": len(demo_users),
        "test_credentials": {
            "maria": {"email": "maria@cloudwalk.com", "password": "senha123"},
            "joao": {"email": "joao@cloudwalk.com", "password": "senha123"},
            "ana": {"email": "ana@cloudwalk.com", "password": "senha123"}
        }
    }

# Advanced Features

@app.get("/api/admin/stats")
async def get_admin_stats():
    """Admin endpoint for system statistics"""
    total_clicks = sum(ref.get('click_count', 0) for ref in referrals_db.values())
    total_registrations = sum(ref.get('registration_count', 0) for ref in referrals_db.values())
    
    return {
        "total_users": len(users_db),
        "total_referrals": sum(user.get("total_referrals", 0) for user in users_db.values()),
        "total_clicks": total_clicks,
        "total_registrations": total_registrations,
        "conversion_rate": (total_registrations / total_clicks * 100) if total_clicks > 0 else 0,
        "total_earnings_paid": sum(user.get("total_earnings", 0) for user in users_db.values())
    }

@app.get("/api/leaderboard")
async def get_leaderboard():
    """Get top performers leaderboard"""
    users_list = list(users_db.values())
    users_list.sort(key=lambda x: x.get('total_referrals', 0), reverse=True)
    
    leaderboard = []
    for rank, user in enumerate(users_list[:10], 1):
        leaderboard.append({
            "rank": rank,
            "user_id": user["id"],
            "user_name": f"{user['first_name']} {user['last_name']}",
            "total_referrals": user.get("total_referrals", 0),
            "total_earnings": user.get("total_earnings", 0)
        })
    
    return {"leaderboard": leaderboard}

@app.get("/api/achievements")
async def get_user_achievements(current_user: dict = Depends(get_current_user)):
    """Get user achievements with progress"""
    user_achievements = current_user.get("achievements", [])
    achievements_list = []
    
    for achievement_id, achievement in achievements_db.items():
        is_unlocked = achievement_id in user_achievements
        
        # Calculate progress
        if achievement["category"] == "referrals":
            progress = min(current_user.get("total_referrals", 0) / achievement["target_value"], 1.0)
        elif achievement["category"] == "earnings":
            progress = min(current_user.get("total_earnings", 0) / achievement["target_value"], 1.0)
        else:
            progress = 0.0
        
        achievements_list.append({
            **achievement,
            "is_unlocked": is_unlocked,
            "progress": progress
        })
    
    # Sort: unlocked first, then by category
    achievements_list.sort(key=lambda x: (not x["is_unlocked"], x["category"]))
    
    return {"achievements": achievements_list}

@app.post("/api/chat")
async def chat_with_ai(chat_request: ChatRequest, current_user: dict = Depends(get_current_user)):
    """ChatGPT AI Agent for customer support and analytics"""
    
    # Check if OpenAI client is configured
    if not openai_client:
        return {
            "response": "❌ OpenAI API key not configured. Please add OPENAI_API_KEY to your .env file to enable the ChatGPT agent.",
            "user_stats": {
                "total_earnings": current_user.get("total_earnings", 0),
                "total_referrals": current_user.get("total_referrals", 0),
                "referral_code": current_user.get("referral_code", "")
            }
        }
    
    try:
        # Create system context with user data
        system_context = f"""
        You are a helpful AI assistant for CloudWalk's referral program. 
        Current user: {current_user['first_name']} {current_user['last_name']}
        User earnings: ${current_user.get('total_earnings', 0)}
        User referrals: {current_user.get('total_referrals', 0)}
        User referral code: {current_user.get('referral_code', '')}
        
        Help users with:
        - Understanding the referral program ($25 for new users, $50 for referrers)
        - Tips to increase referrals
        - Account and earnings information
        - General CloudWalk questions
        
        Be helpful, friendly, and encouraging. Always respond in a concise and actionable way.
        """
        
        # Call OpenAI API with new client
        response = openai_client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": system_context},
                {"role": "user", "content": chat_request.message}
            ],
            max_tokens=200,
            temperature=0.7
        )
        
        ai_response = response.choices[0].message.content
        
        return {
            "response": ai_response,
            "user_stats": {
                "total_earnings": current_user.get("total_earnings", 0),
                "total_referrals": current_user.get("total_referrals", 0),
                "referral_code": current_user.get("referral_code", "")
            }
        }
        
    except Exception as e:
        # Return error details for debugging
        return {
            "response": f"❌ OpenAI API Error: {str(e)}. Please check your API key and try again.",
            "user_stats": {
                "total_earnings": current_user.get("total_earnings", 0),
                "total_referrals": current_user.get("total_referrals", 0),
                "referral_code": current_user.get("referral_code", "")
            }
        }

if __name__ == "__main__":
    print("🚀 Starting CloudWalk Referral API with FastAPI")
    print("📊 Automatic API Documentation: http://localhost:3002/docs")
    print("📖 Alternative Docs: http://localhost:3002/redoc")
    print("🎯 Health Check: http://localhost:3002/health")
    if openai_client:
        print("🤖 ChatGPT Agent: ENABLED ✅")
    else:
        print("🤖 ChatGPT Agent: DISABLED ❌ (Add OPENAI_API_KEY to .env)")
    print("")
    
    uvicorn.run("main:app", host="0.0.0.0", port=3002, reload=True)