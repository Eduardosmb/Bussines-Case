#!/bin/bash

echo "🚀 CloudWalk FastAPI Backend Setup"
echo "=================================="

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.8+"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "📦 Creating Python virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "⚡ Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing FastAPI dependencies..."
pip install -r requirements.txt

# Start the FastAPI server
echo "🚀 Starting CloudWalk FastAPI Server..."
echo "📊 API Documentation will be available at: http://localhost:3002/docs"
echo "🎯 Health Check: http://localhost:3002/health"
echo ""

python3 main.py
