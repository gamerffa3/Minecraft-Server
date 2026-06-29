#!/bin/bash

# ============================================
# SERVER STATUS SCRIPT
# ============================================

source env

echo "========================================="
echo "📊 SERVER STATUS"
echo "========================================="

# Check if server is running
if pgrep -f "paper-.*.jar" > /dev/null; then
    echo "🟢 Server: RUNNING"
    echo "📂 PID: $(pgrep -f "paper-.*.jar")"
else
    echo "🔴 Server: STOPPED"
fi

echo ""

# Check Tailscale
if command -v tailscale &> /dev/null; then
    TAILSCALE_IP=$(tailscale ip 2>/dev/null)
    if [ -n "$TAILSCALE_IP" ]; then
        echo "🔗 Tailscale: CONNECTED ($TAILSCALE_IP)"
    else
        echo "🔗 Tailscale: NOT CONNECTED"
    fi
else
    echo "🔗 Tailscale: NOT INSTALLED"
fi

echo ""

# Backup stats
if [ -d "$BACKUP_DIR/backups" ]; then
    TOTAL_BACKUPS=$(find "$BACKUP_DIR/backups" -name "*.tar.gz" 2>/dev/null | wc -l)
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR/backups" 2>/dev/null | cut -f1 || echo "0")
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR/backups"/*/*.tar.gz 2>/dev/null | head -n1)
    
    echo "📦 Backups: $TOTAL_BACKUPS"
    echo "📂 Backup Size: $BACKUP_SIZE"
    
    if [ -n "$LATEST_BACKUP" ]; then
        echo "📅 Latest: $(basename $LATEST_BACKUP)"
    fi
fi

echo ""
echo "========================================="
