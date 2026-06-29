#!/bin/bash

# ============================================
# LOAD CONFIG
# ============================================
source env

# ============================================
# COLORS
# ============================================
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}🔄 REAL-TIME BACKUP WATCHER${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "⏱️  Interval: $REALTIME_INTERVAL seconds"
echo -e "📂 Backup folder: $BACKUP_DIR"
echo -e "${BLUE}=========================================${NC}"

# Create log file
mkdir -p "$LOG_DIR"

# Counter
COUNT=0

while true; do
    COUNT=$((COUNT + 1))
    echo ""
    echo -e "${YELLOW}[$COUNT] 📝 Creating real-time backup...${NC}"
    
    # Create backup
    ./backup.sh realtime
    
    # Check if backup was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Backup successful!${NC}"
        echo "[$(date)] Backup #$COUNT successful" >> "$LOG_DIR/realtime.log"
    else
        echo -e "${RED}❌ Backup failed!${NC}"
        echo "[$(date)] Backup #$COUNT FAILED" >> "$LOG_DIR/realtime.log"
    fi
    
    echo -e "${BLUE}💤 Sleeping for $REALTIME_INTERVAL seconds...${NC}"
    sleep "$REALTIME_INTERVAL"
done
