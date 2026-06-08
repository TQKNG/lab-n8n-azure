#!/bin/bash

# n8n Health Check Script
# Monitors n8n and Caddy health

echo "🏥 n8n Health Check"
echo "==================="
echo ""

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker daemon not running"
    exit 1
fi

echo "✅ Docker daemon: running"

# Check containers
echo ""
echo "📋 Container Status:"
docker ps --filter "name=n8n" --filter "name=caddy" --format "table {{.Names}}\t{{.Status}}\t{{.Health}}"

# Check n8n health
echo ""
echo "🔍 n8n Health:"
N8N_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/healthz 2>/dev/null || echo "000")

if [ "$N8N_HEALTH" = "200" ]; then
    echo "✅ n8n health endpoint: OK ($N8N_HEALTH)"
else
    echo "❌ n8n health endpoint: FAILED ($N8N_HEALTH)"
fi

# Check Caddy health
echo ""
echo "🔍 Caddy Health:"
CADDY_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:2019/metrics 2>/dev/null || echo "000")

if [ "$CADDY_HEALTH" = "200" ]; then
    echo "✅ Caddy metrics endpoint: OK ($CADDY_HEALTH)"
else
    echo "❌ Caddy metrics endpoint: FAILED ($CADDY_HEALTH)"
fi

# Check disk usage
echo ""
echo "💾 Disk Usage:"
df -h /var/lib/docker | tail -1

# Check volumes
echo ""
echo "📦 Volumes:"
docker volume ls | grep n8n

echo ""
echo "✅ Health check complete"