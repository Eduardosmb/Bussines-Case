from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, timedelta
from passlib.context import CryptContext
from jose import JWTError, jwt
import uuid
import uvicorn

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

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
security = HTTPBearer()

# In-memory database (mock data)
users_db = {}
referrals_db = {}
clicks_db = []

# Pydantic models
class UserRegister(BaseModel):
    firstName: str
    lastName: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: str
    first_name: str
    last_name: str
    email: str
    referral_code: str
    total_referrals: int
    total_earnings: float
    created_at: datetime

class CreateReferral(BaseModel):
    userName: str

class ReferralResponse(BaseModel):
    id: str
    user_id: str
    user_name: str
    link_code: str
    full_url: str
    click_count: int
    registration_count: int
    created_at: datetime

class AnalyticsResponse(BaseModel):
    userStats: dict
    clickStats: List[dict]
    topLinks: List[dict]

class Token(BaseModel):
    access_token: str
    token_type: str

# Utility functions
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def generate_referral_code(length=6):
    """Generate a unique referral code"""
    import random
    import string
    while True:
        code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))
        if not any(user['referral_code'] == code for user in users_db.values()):
            return code

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
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        token = credentials.credentials
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = users_db.get(user_id)
    if user is None:
        raise credentials_exception
    return user

# API Routes

@app.get("/")
async def root():
    return {
        "message": "CloudWalk Referral API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs",
        "features": [
            "User Authentication",
            "Referral Management", 
            "Analytics Dashboard",
            "Real-time Tracking"
        ]
    }

@app.get("/health")
async def health_check():
    return {
        "status": "OK", 
        "message": "CloudWalk Referral API is running (FastAPI)",
        "timestamp": datetime.utcnow().isoformat(),
        "users_count": len(users_db),
        "referrals_count": len(referrals_db)
    }

@app.post("/api/register", response_model=dict)
async def register_user(user_data: UserRegister):
    # Check if user exists
    if any(user['email'] == user_data.email for user in users_db.values()):
        raise HTTPException(
            status_code=400,
            detail="User already exists"
        )
    
    # Create new user
    user_id = str(uuid.uuid4())
    hashed_password = get_password_hash(user_data.password)
    referral_code = generate_referral_code()
    
    new_user = {
        "id": user_id,
        "first_name": user_data.firstName,
        "last_name": user_data.lastName,
        "email": user_data.email,
        "password_hash": hashed_password,
        "referral_code": referral_code,
        "total_referrals": 0,
        "total_earnings": 0.0,
        "created_at": datetime.utcnow()
    }
    
    users_db[user_id] = new_user
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user_id, "email": user_data.email},
        expires_delta=access_token_expires
    )
    
    # Remove password from response
    user_response = {k: v for k, v in new_user.items() if k != 'password_hash'}
    
    return {
        "message": "User created successfully",
        "user": user_response,
        "token": access_token
    }

@app.post("/api/login", response_model=dict)
async def login_user(user_data: UserLogin):
    # Find user
    user = None
    for u in users_db.values():
        if u['email'] == user_data.email:
            user = u
            break
    
    if not user or not verify_password(user_data.password, user['password_hash']):
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["id"], "email": user["email"]},
        expires_delta=access_token_expires
    )
    
    # Remove password from response
    user_response = {k: v for k, v in user.items() if k != 'password_hash'}
    
    return {
        "message": "Login successful",
        "user": user_response,
        "token": access_token
    }

@app.get("/api/profile", response_model=dict)
async def get_profile(current_user: dict = Depends(get_current_user)):
    user_response = {k: v for k, v in current_user.items() if k != 'password_hash'}
    return {"user": user_response}

@app.get("/api/referrals", response_model=dict)
async def get_referrals(current_user: dict = Depends(get_current_user)):
    user_referrals = [ref for ref in referrals_db.values() if ref['user_id'] == current_user['id']]
    return {"referrals": user_referrals}

@app.post("/api/referrals", response_model=dict)
async def create_referral(referral_data: CreateReferral, current_user: dict = Depends(get_current_user)):
    referral_id = str(uuid.uuid4())
    link_code = f"{current_user['referral_code']}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
    full_url = f"http://localhost:8080/register?ref={link_code}"
    
    new_referral = {
        "id": referral_id,
        "user_id": current_user['id'],
        "user_name": referral_data.userName,
        "link_code": link_code,
        "full_url": full_url,
        "click_count": 0,
        "registration_count": 0,
        "created_at": datetime.utcnow()
    }
    
    referrals_db[referral_id] = new_referral
    
    return {
        "message": "Referral link created successfully",
        "referral": new_referral
    }

@app.get("/api/analytics", response_model=dict)
async def get_analytics(current_user: dict = Depends(get_current_user)):
    # Generate mock analytics data
    user_referrals = [ref for ref in referrals_db.values() if ref['user_id'] == current_user['id']]
    
    # Mock click stats for the last 7 days
    import random
    click_stats = []
    for i in range(7):
        date = (datetime.now() - timedelta(days=i)).strftime('%Y-%m-%d')
        click_stats.append({
            "date": date,
            "clicks": random.randint(0, 25),
            "conversions": random.randint(0, 5)
        })
    
    return {
        "userStats": {
            "total_referrals": current_user['total_referrals'],
            "total_earnings": current_user['total_earnings']
        },
        "clickStats": click_stats[::-1],  # Reverse to show oldest first
        "topLinks": user_referrals[:5]  # Top 5 links
    }

@app.post("/api/track-click/{link_code}")
async def track_click(link_code: str, ip_address: str = None, user_agent: str = None):
    # Find the referral link
    referral = None
    for ref in referrals_db.values():
        if ref['link_code'] == link_code:
            referral = ref
            break
    
    if not referral:
        raise HTTPException(status_code=404, detail="Referral link not found")
    
    # Record the click
    click_record = {
        "id": str(uuid.uuid4()),
        "link_code": link_code,
        "ip_address": ip_address,
        "user_agent": user_agent,
        "clicked_at": datetime.utcnow(),
        "completed_registration": False
    }
    clicks_db.append(click_record)
    
    # Update click count
    referral['click_count'] += 1
    
    return {"message": "Click tracked successfully"}

@app.post("/api/demo/seed")
async def create_demo_data():
    """Create demo data for testing"""
    global users_db, referrals_db, clicks_db
    
    # Clear existing data
    users_db.clear()
    referrals_db.clear()
    clicks_db.clear()
    
    # Create demo user
    demo_user_id = str(uuid.uuid4())
    demo_user = {
        "id": demo_user_id,
        "first_name": "John",
        "last_name": "Doe", 
        "email": "demo@cloudwalk.com",
        "password_hash": get_password_hash("demo123"),
        "referral_code": "DEMO123",
        "total_referrals": 5,
        "total_earnings": 125.50,
        "created_at": datetime.utcnow()
    }
    users_db[demo_user_id] = demo_user
    
    # Create demo referral links
    for i in range(1, 4):
        ref_id = str(uuid.uuid4())
        referrals_db[ref_id] = {
            "id": ref_id,
            "user_id": demo_user_id,
            "user_name": f"Friend {i}",
            "link_code": f"DEMO123-{i}",
            "full_url": f"http://localhost:8080/register?ref=DEMO123-{i}",
            "click_count": random.randint(5, 50),
            "registration_count": random.randint(1, 10),
            "created_at": datetime.utcnow()
        }
    
    return {
        "message": "Demo data created successfully",
        "credentials": {
            "email": "demo@cloudwalk.com",
            "password": "demo123"
        },
        "users_created": 1,
        "referrals_created": 3
    }

# Advanced Features

@app.get("/api/admin/stats")
async def get_admin_stats():
    """Admin endpoint for system statistics"""
    total_clicks = sum(ref['click_count'] for ref in referrals_db.values())
    total_registrations = sum(ref['registration_count'] for ref in referrals_db.values())
    
    return {
        "total_users": len(users_db),
        "total_referrals": len(referrals_db),
        "total_clicks": total_clicks,
        "total_registrations": total_registrations,
        "conversion_rate": (total_registrations / total_clicks * 100) if total_clicks > 0 else 0
    }

@app.get("/api/leaderboard")
async def get_leaderboard():
    """Get top performers leaderboard"""
    users_list = list(users_db.values())
    users_list.sort(key=lambda x: x['total_referrals'], reverse=True)
    
    leaderboard = []
    for i, user in enumerate(users_list[:10]):
        leaderboard.append({
            "rank": i + 1,
            "user_name": f"{user['first_name']} {user['last_name']}",
            "total_referrals": user['total_referrals'],
            "total_earnings": user['total_earnings']
        })
    
    return {"leaderboard": leaderboard}

if __name__ == "__main__":
    import random
    print("🚀 Starting CloudWalk Referral API with FastAPI")
    print("📊 Automatic API Documentation: http://localhost:3002/docs")
    print("📖 Alternative Docs: http://localhost:3002/redoc")
    print("🎯 Health Check: http://localhost:3002/health")
    
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=3002,
        reload=True,  # Auto-reload on code changes
        log_level="info"
    )
