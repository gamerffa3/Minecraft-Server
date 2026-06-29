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

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}🎮 MINECRAFT SERVER STARTING${NC}"
echo -e "${BLUE}=========================================${NC}"

# ============================================
# STEP 1: CHECK TAILSCALE
# ============================================
echo ""
echo -e "${BLUE}🔍 Step 1: Checking Tailscale...${NC}"

if command -v tailscale &> /dev/null; then
    TAILSCALE_STATUS=$(tailscale status 2>/dev/null | grep -o "Connected" || echo "Not connected")
    if [ "$TAILSCALE_STATUS" == "Connected" ]; then
        TAILSCALE_IP=$(tailscale ip)
        echo -e "${GREEN}   ✅ Tailscale connected! IP: $TAILSCALE_IP${NC}"
    else
        echo -e "${YELLOW}   ⚠️ Tailscale not connected. Run: tailscale up${NC}"
    fi
else
    echo -e "${YELLOW}   ⚠️ Tailscale not installed. Install: curl -fsSL https://tailscale.com/install.sh | sh${NC}"
fi

# ============================================
# STEP 2: CREATE PRE-START BACKUP
# ============================================
echo ""
echo -e "${YELLOW}📦 Step 2: Creating pre-start backup...${NC}"
./backup.sh start

# ============================================
# STEP 3: DELETE OLD SERVER
# ============================================
echo ""
echo -e "${YELLOW}🗑️ Step 3: Removing old server...${NC}"
rm -rf "$SERVER_DIR"

# ============================================
# STEP 4: CLONE FRESH SERVER
# ============================================
echo ""
echo -e "${YELLOW}📥 Step 4: Downloading fresh server...${NC}"

# Clone server
git clone https://github.com/gamerffa3/Minecraft-Server.git "$SERVER_DIR" 2>/dev/null || echo "   ⚠️ Using existing files"

# Create necessary folders
mkdir -p "$SERVER_DIR/plugins"

# Copy plugins
echo -e "${BLUE}📦 Copying plugins...${NC}"
cp *.jar "$SERVER_DIR/plugins/" 2>/dev/null || echo "   ⚠️ No plugins found"

# Download Paper if not exists
if [ ! -f "$SERVER_DIR/server.jar" ]; then
    echo -e "${BLUE}📥 Downloading Paper server...${NC}"
    wget -q https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/404/downloads/paper-1.20.4-404.jar -O "$SERVER_DIR/server.jar"
fi

# Accept EULA
echo "eula=true" > "$SERVER_DIR/eula.txt"

# ============================================
# STEP 5: RESTORE LATEST WORLD
# ============================================
echo ""
echo -e "${YELLOW}🔄 Step 5: Restoring latest world...${NC}"

LATEST_BACKUP=$(ls -t "$BACKUP_DIR/backups"/*/*.tar.gz 2>/dev/null | head -n1)

if [ -n "$LATEST_BACKUP" ]; then
    echo "   Found: $(basename $LATEST_BACKUP)"
    cd "$BACKUP_DIR/backups"
    tar -xzf "$(basename $LATEST_BACKUP)" -C "../../$SERVER_DIR/" 2>/dev/null
    cd ../..
    echo -e "${GREEN}   ✅ World restored${NC}"
else
    echo -e "${YELLOW}   ⚠️ No backup found, starting fresh${NC}"
fi

# ============================================
# STEP 6: CREATE SERVER.PROPERTIES
# ============================================
echo ""
echo -e "${BLUE}⚙️ Step 6: Creating server.properties...${NC}"

cat > "$SERVER_DIR/server.properties" << EOF
# Minecraft server properties
server-port=$SERVER_PORT
max-players=$MAX_PLAYERS
view-distance=12
simulation-distance=8
gamemode=0
difficulty=3
spawn-protection=16
online-mode=false
force-gamemode=false
allow-flight=true
allow-nether=true
allow-end=true
level-name=world
level-type=default
motd=Welcome to $SERVER_NAME! | Tailscale: $TAILSCALE_IP
enable-query=true
enable-rcon=true
rcon-password=minecraft123
rcon-port=25575
max-tick-time=60000
network-compression-threshold=256
EOF

echo -e "${GREEN}   ✅ server.properties created${NC}"

# ============================================
# STEP 7: SHOW INFO
# ============================================
echo ""
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}🚀 Step 7: Starting Minecraft server...${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "🖥️  RAM: $SERVER_RAM"
echo -e "🎮 Mode: $SERVER_MODE"
echo -e "🌐 Port: $SERVER_PORT"
echo -e "🔗 Tailscale IP: $TAILSCALE_IP"
echo -e "📂 Plugins: $(ls -1 $SERVER_DIR/plugins/ 2>/dev/null | wc -l) files"
echo -e "${BLUE}=========================================${NC}"

# ============================================
# STEP 8: START SERVER
# ============================================
cd "$SERVER_DIR"
java -Xmx"$SERVER_RAM" -Xms"$SERVER_RAM" -jar server.jar nogui

# ============================================
# STEP 9: WHEN SERVER STOPS
# ============================================
cd ..
echo ""
echo -e "${YELLOW}🛑 Server stopped! Creating final backup...${NC}"
./backup.sh stop
./backup.sh cleanup

echo ""
echo -e "${GREEN}✅ Server shutdown complete!${NC}"
