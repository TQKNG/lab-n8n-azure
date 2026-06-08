#!/bin/bash
set -e

# n8n Backup Script
# Creates backup of n8n data

echo "💾 n8n Backup Script"
echo "===================="
echo ""

# Configuration
BACKUP_DIR="/opt/n8n/backups"
DATA_DIR="/opt/n8n"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="n8n-backup-$TIMESTAMP"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "📋 Creating backup: $BACKUP_NAME"

# Create backup archive
tar -czf "$BACKUP_PATH.tar.gz" \
    -C /var/lib/docker/volumes \
    n8n-azure-automation_n8n_data \
    2>/dev/null || echo "⚠️  Warning: Could not backup volume data"

# Backup configuration files
mkdir -p "$BACKUP_PATH"
cp "$DATA_DIR/docker-compose.yml" "$BACKUP_PATH/" 2>/dev/null || true
cp "$DATA_DIR/.env" "$BACKUP_PATH/" 2>/dev/null || true
cp "$DATA_DIR/caddy/Caddyfile" "$BACKUP_PATH/" 2>/dev/null || true

# Export database (if using SQLite)
docker exec n8n sqlite3 /home/node/.n8n/database.sqlite ".backup /home/node/.n8n/database.backup" 2>/dev/null || true

# Create metadata
cat > "$BACKUP_PATH/metadata.txt" << EOFMETA
Backup Created: $(date)
n8n Version: $(docker exec n8n n8n --version 2>/dev/null || echo "unknown")
Hostname: $(hostname)
EOFMETA

echo "✅ Backup created: $BACKUP_PATH.tar.gz"
echo "📊 Backup size: $(du -h "$BACKUP_PATH.tar.gz" | cut -f1)"

# Cleanup old backups (keep last 7)
cd "$BACKUP_DIR"
ls -t | tail -n +8 | xargs -r rm -rf
echo "🧹 Cleaned up old backups (keeping last 7)"

echo ""
echo "✅ Backup complete!"