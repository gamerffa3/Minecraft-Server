#!/bin/bash

# ============================================
# LOAD CONFIG
# ============================================
source env

# ============================================
# COLORS
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================
# VARIABLES
# ============================================
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H-%M-%S")

# ============================================
# FUNCTION: Initialize Backup Folder
# ============================================
init_backup() {
    echo -e "${BLUE}📦 Creating backup folder...${NC}"
    
    # Create backup folder
    mkdir -p "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/backups"
    mkdir -p "$LOG_DIR"
    
    echo -e "${GREEN}✅ Backup folder created: $BACKUP_DIR${NC}"
}

# ============================================
# FUNCTION: Initialize GitHub Repo
# ============================================
init_repo() {
    echo -e "${BLUE}📦 Initializing GitHub repository...${NC}"
    
    init_backup
    
    if [ ! -d "$BACKUP_DIR/.git" ]; then
        echo "   Cloning repository..."
        git clone "$GITHUB_REPO" "$BACKUP_DIR"
        cd "$BACKUP_DIR"
        git config user.name "Minecraft Backup Bot"
        git config user.email "backup@minecraft.com"
        cd ..
    else
        echo "   Updating repository..."
        cd "$BACKUP_DIR"
        git pull origin "$GITHUB_BRANCH" 2>/dev/null || true
        cd ..
    fi
    
    echo -e "${GREEN}✅ Repository ready${NC}"
}

# ============================================
# FUNCTION: Create Backup
# ============================================
create_backup() {
    echo -e "${YELLOW}📝 Creating backup: $DATE/$TIME${NC}"
    
    init_repo
    
    BACKUP_PATH="$BACKUP_DIR/backups/$DATE/$TIME"
    mkdir -p "$BACKUP_PATH"
    
    # Check if server exists
    if [ ! -d "$SERVER_DIR/world" ]; then
        echo -e "${YELLOW}   ⚠️ No server found, skipping backup${NC}"
        return
    fi
    
    # Copy worlds
    echo -e "${BLUE}🌍 Copying worlds...${NC}"
    cp -r "$SERVER_DIR/world" "$BACKUP_PATH/" 2>/dev/null
    cp -r "$SERVER_DIR/world_nether" "$BACKUP_PATH/" 2>/dev/null
    cp -r "$SERVER_DIR/world_the_end" "$BACKUP_PATH/" 2>/dev/null
    
    # Copy configs
    echo -e "${BLUE}📄 Copying configs...${NC}"
    cp "$SERVER_DIR/server.properties" "$BACKUP_PATH/" 2>/dev/null
    cp "$SERVER_DIR/whitelist.json" "$BACKUP_PATH/" 2>/dev/null
    cp "$SERVER_DIR/ops.json" "$BACKUP_PATH/" 2>/dev/null
    cp "$SERVER_DIR/banned-players.json" "$BACKUP_PATH/" 2>/dev/null
    cp "$SERVER_DIR/banned-ips.json" "$BACKUP_PATH/" 2>/dev/null
    
    # Copy plugins config
    if [ -d "$SERVER_DIR/plugins" ]; then
        mkdir -p "$BACKUP_PATH/plugins"
        cp -r "$SERVER_DIR/plugins/config" "$BACKUP_PATH/plugins/" 2>/dev/null
    fi
    
    # Metadata
    PLAYERS=$(ls "$SERVER_DIR/world/playerdata" 2>/dev/null | wc -l)
    WORLD_SIZE=$(du -sm "$SERVER_DIR/world" 2>/dev/null | cut -f1 || echo 0)
    
    cat > "$BACKUP_PATH/metadata.json" << EOF
{
    "timestamp": "$TIMESTAMP",
    "date": "$DATE",
    "time": "$TIME",
    "players": $PLAYERS,
    "world_size_mb": $WORLD_SIZE,
    "tailscale_ip": "$TAILSCALE_IP",
    "server_mode": "$SERVER_MODE"
}
EOF
    
    # Compress
    echo -e "${BLUE}🗜️ Compressing backup...${NC}"
    cd "$BACKUP_DIR/backups/$DATE"
    tar -czf "$TIME.tar.gz" "$TIME"
    rm -rf "$TIME"
    cd ../../..
    
    # Upload to GitHub
    echo -e "${BLUE}📤 Uploading to GitHub...${NC}"
    cd "$BACKUP_DIR"
    git add .
    git commit -m "Backup: $DATE $TIME | Players: $PLAYERS | Size: ${WORLD_SIZE}MB"
    git push origin "$GITHUB_BRANCH"
    cd ..
    
    echo -e "${GREEN}✅ Backup uploaded: $DATE/$TIME.tar.gz${NC}"
    
    # Log backup
    echo "[$TIMESTAMP] Backup: $DATE/$TIME.tar.gz | Players: $PLAYERS | Size: ${WORLD_SIZE}MB" >> "$LOG_DIR/backup.log"
}

# ============================================
# FUNCTION: Delete Old Backups
# ============================================
delete_old() {
    echo -e "${YELLOW}🧹 Cleaning old backups...${NC}"
    
    if [ ! -d "$BACKUP_DIR/backups" ]; then
        echo -e "${YELLOW}   ⚠️ No backups folder found${NC}"
        return
    fi
    
    cd "$BACKUP_DIR/backups"
    
    # Keep last 7 daily backups
    TOTAL=$(ls -d */ 2>/dev/null | wc -l)
    if [ $TOTAL -gt $KEEP_DAILY ]; then
        TO_DELETE=$(ls -d */ | head -n -$KEEP_DAILY)
        for old in $TO_DELETE; do
            echo "   Deleting: $old"
            rm -rf "$old"
        done
    fi
    
    cd ../..
    
    # Upload deletion to GitHub
    cd "$BACKUP_DIR"
    git add .
    git commit -m "Auto delete old backups: $(date)" 2>/dev/null || true
    git push origin "$GITHUB_BRANCH" 2>/dev/null || true
    cd ..
    
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# ============================================
# MAIN: Run based on argument
# ============================================
case "$1" in
    start|stop|realtime)
        create_backup
        ;;
    cleanup)
        delete_old
        ;;
    *)
        echo "Usage: $0 {start|stop|realtime|cleanup}"
        exit 1
        ;;
esac
