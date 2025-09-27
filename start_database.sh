#!/bin/bash

echo "🗄️ Starting CloudWalk PostgreSQL Database..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first:"
    echo "   sudo apt install docker.io docker-compose"
    exit 1
fi

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose is not available. Please install it:"
    echo "   sudo apt install docker-compose"
    exit 1
fi

# Start the database
echo "🚀 Starting PostgreSQL with Docker Compose..."
$COMPOSE_CMD up -d

# Wait a moment for the database to start
echo "⏳ Waiting for database to initialize..."
sleep 5

# Check if the database is running
if $COMPOSE_CMD ps | grep -q "cloudwalk_postgres"; then
    echo "✅ PostgreSQL is running!"
    echo ""
    echo "📊 Database Information:"
    echo "   Host: localhost"
    echo "   Port: 5432"
    echo "   Database: cloudwalk_referrals"
    echo "   User: cloudwalk"
    echo "   Password: cloudwalk123"
    echo ""
    echo "🔧 To stop the database: $COMPOSE_CMD down"
    echo "🔍 To view logs: $COMPOSE_CMD logs postgres"
    echo "💾 To connect manually: psql -h localhost -U cloudwalk -d cloudwalk_referrals"
else
    echo "❌ Failed to start PostgreSQL. Check the logs:"
    $COMPOSE_CMD logs postgres
fi


