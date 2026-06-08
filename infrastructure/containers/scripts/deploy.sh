#!/bin/bash
set -e

# n8n Deployment Script
# Deploys or updates n8n containers on Azure VM

echo "🚀 n8n Deployment Script"
echo "========================"
echo ""

# Configuration
N8N_DIR="/opt/n8n"
BACKUP_DIR="/opt/n8n/backups"
LOG_FILE="/var/log/n8n/deployment.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
error_exit() {
    log "ERROR: $1"
    exit 1
}

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    log "⚠️  Please run as root or with sudo"
    exit 1
fi

log "📋 Starting n8n deployment..."

# Step 1: Check prerequisites
log "🔍 Checking prerequisites..."

command -v docker >/dev/null 2>&1 || error_exit "Docker not installed"
command -v docker compose >/dev/null 2>&1 || error_exit "Docker Compose not installed"

log "✅ Prerequisites satisfied"

# Step 2: Create directories
log "📁 Creating directories..."

mkdir -p "$N8N_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname $LOG_FILE)"
mkdir -p "$N8N_DIR/caddy"
mkdir -p "$N8N_DIR/n8n"

log "✅ Directories created"

# Step 3: Check for existing deployment
if [ -f "$N8N_DIR/docker-compose.yml" ]; then
    log "⚠️  Existing deployment found"
    
    # Backup current configuration
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
    log "💾 Creating backup: $BACKUP_NAME"
    
    mkdir -p "$BACKUP_DIR/$BACKUP_NAME"
    cp "$N8N_DIR/docker-compose.yml" "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true
    cp "$N8N_DIR/.env" "$BACKUP_DIR/$BACKUP_NAME/" 2>/dev/null || true
    
    log "✅ Backup created"
    
    # Stop existing containers
    log "🛑 Stopping existing containers..."
    cd "$N8N_DIR"
    docker compose down || log "⚠️  No containers to stop"
fi

# Step 4: Copy new configuration files
log "📋 Copying configuration files..."

# Files should already be in place from cloud-init
# Just verify they exist
[ -f "$N8N_DIR/docker-compose.yml" ] || error_exit "docker-compose.yml not found"
[ -f "$N8N_DIR/caddy/Caddyfile" ] || error_exit "Caddyfile not found"

log "✅ Configuration files verified"

# Step 5: Pull images
log "📥 Pulling Docker images..."

cd "$N8N_DIR"
docker compose pull || error_exit "Failed to pull images"

log "✅ Images pulled"

# Step 6: Start containers
log "🚀 Starting containers..."

docker compose up -d || error_exit "Failed to start containers"

log "✅ Containers started"

# Step 7: Wait for services to be healthy
log "⏳ Waiting for services to be healthy..."

TIMEOUT=120
ELAPSED=0

while [ $ELAPSED -lt $TIMEOUT ]; do
    N8N_HEALTHY=$(docker inspect --format='{{.State.Health.Status}}' n8n 2>/dev/null || echo "starting")
    CADDY_HEALTHY=$(docker inspect --format='{{.State.Health.Status}}' caddy 2>/dev/null || echo "starting")
    
    if [ "$N8N_HEALTHY" = "healthy" ] && [ "$CADDY_HEALTHY" = "healthy" ]; then
        log "✅ All services healthy"
        break
    fi
    
    log "⏳ Waiting... (n8n: $N8N_HEALTHY, caddy: $CADDY_HEALTHY)"
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

if [ $ELAPSED -ge $TIMEOUT ]; then
    log "⚠️  Timeout waiting for services to be healthy"
    log "Check logs with: docker logs n8n"
fi

# Step 8: Show status
log ""
log "📊 Container Status:"
docker ps -a --filter "name=n8n" --filter "name=caddy" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

log ""
log "🎉 Deployment complete!"
log ""
log "📋 Next steps:"
log "   1. Check logs: docker logs n8n"
log "   2. Check logs: docker logs caddy"
log "   3. Verify: curl -k https://localhost/healthz"
log ""