#!/bin/bash

# ============================================
# COMPLETE INSTALLATION SCRIPT
# ============================================

echo "========================================="
echo "🚀 MINECRAFT SERVER INSTALLATION"
echo "========================================="

# ============================================
# STEP 1: Update System
# ============================================
echo ""
echo "📦 Step 1: Updating system..."
sudo apt update && sudo apt upgrade -y

# ============================================
# STEP 2: Install Dependencies
# ============================================
echo ""
echo "📦 Step 2: Installing dependencies..."
sudo apt install -y git wget curl openjdk-21-jre-headless netcat-openbsd

# ============================================
# STEP 3: Install Tailscale
# ============================================
echo ""
echo "📦 Step 3: Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

echo ""
echo "========================================="
echo "✅ TAILSCALE SETUP"
echo "========================================="
echo "Run this command to connect Tailscale:"
echo "  tailscale up"
echo ""
echo "Then check your IP:"
echo "  tailscale ip"
echo "========================================="

# ============================================
# STEP 4: Make Scripts Executable
# ============================================
echo ""
echo "📦 Step 4: Making scripts executable..."
chmod +x *.sh

# ============================================
# STEP 5: Create Folders
# ============================================
echo ""
echo "📦 Step 5: Creating folders..."
mkdir -p server
mkdir -p server/plugins
mkdir -p logs
mkdir -p github-backup/backups

# ============================================
# STEP 6: Download Paper
# ============================================
echo ""
echo "📦 Step 6: Downloading Paper server..."
cd server
wget -q https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/404/downloads/paper-1.20.4-404.jar
mv paper-1.20.4-404.jar server.jar
cd ..

# ============================================
# STEP 7: Accept EULA
# ============================================
echo "eula=true" > server/eula.txt

# ============================================
# STEP 8: Final Instructions
# ============================================
echo ""
echo "========================================="
echo "✅ INSTALLATION COMPLETE!"
echo "========================================="
echo ""
echo "📋 Next Steps:"
echo "1. Edit env file with your settings"
echo "   nano env"
echo ""
echo "2. Connect Tailscale"
echo "   tailscale up"
echo ""
echo "3. Start server"
echo "   ./start.sh"
echo ""
echo "4. For real-time backup (another terminal)"
echo "   ./realtime.sh"
echo ""
echo "========================================="
