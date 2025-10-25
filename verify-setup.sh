#!/bin/bash

echo "================================"
echo "EProject Setup Verification"
echo "================================"
echo ""

# Check if Docker is running
echo "1. Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi
echo "✅ Docker is running"
echo ""

# Check if docker-compose is available
echo "2. Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed."
    exit 1
fi
echo "✅ Docker Compose is available"
echo ""

# Check if containers are running
echo "3. Checking running containers..."
CONTAINERS=("eproject-mongodb" "eproject-rabbitmq" "eproject-auth" "eproject-product" "eproject-order" "eproject-gateway")

for container in "${CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        echo "✅ $container is running"
    else
        echo "❌ $container is not running"
    fi
done
echo ""

# Check if services are responding
echo "4. Checking service health..."

echo "Checking MongoDB..."
if docker exec eproject-mongodb mongosh --eval "db.runCommand('ping').ok" --quiet > /dev/null 2>&1; then
    echo "✅ MongoDB is healthy"
else
    echo "⚠️  MongoDB might not be ready yet"
fi

echo "Checking RabbitMQ..."
if docker exec eproject-rabbitmq rabbitmq-diagnostics -q ping > /dev/null 2>&1; then
    echo "✅ RabbitMQ is healthy"
else
    echo "⚠️  RabbitMQ might not be ready yet"
fi

echo "Checking API Gateway..."
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ API Gateway is responding"
else
    echo "⚠️  API Gateway might not be ready yet"
fi
echo ""

echo "================================"
echo "Setup verification complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Test the auth endpoint: curl -X POST http://localhost:3000/auth/register -H 'Content-Type: application/json' -d '{\"username\":\"test\",\"email\":\"test@example.com\",\"password\":\"password123\"}'"
echo "2. View RabbitMQ Management UI: http://localhost:15672 (guest/guest)"
echo "3. Check logs: docker-compose logs -f"
