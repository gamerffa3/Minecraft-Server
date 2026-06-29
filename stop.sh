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
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🛑 Stopping Minecraft server...${NC}"

# Send stop command via RCON
if command -v rcon-cli &> /dev/null; then
    rcon-cli --host localhost --port 25575 --password minecraft123 stop
else
    echo -e "${YELLOW}   ⚠️ rcon-cli not installed, sending stop via port...${NC}"
    echo "stop" | nc localhost 25575 2>/dev/null || echo -e "${RED}   ⚠️ Could not connect to RCON${NC}"
fi

# Wait for server to stop
echo -e "${YELLOW}⏳ Waiting for server to stop...${NC}"
sleep 5

# Check if server stopped
if pgrep -f "paper-.*.jar" > /dev/null; then
    echo -e "${YELLOW}   ⚠️ Server still running, killing...${NC}"
    pkill -f "paper-.*.jar"
    sleep 2
fi

echo -e "${GREEN}✅ Server stopped!${NC}"

# Create final backup
echo -e "${YELLOW}📦 Creating final backup...${NC}"
./backup.sh stop
./backup.sh cleanup

echo -e "${GREEN}✅ Server shutdown complete!${NC}"
