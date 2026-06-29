#!/bin/bash

# ============================================
# TAILSCALE SETUP SCRIPT
# ============================================

echo "========================================="
echo "🔗 TAILSCALE SETUP"
echo "========================================="

# Check if Tailscale is installed
if ! command -v tailscale &> /dev/null; then
    echo "📦 Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

# Start Tailscale
echo ""
echo "🔄 Starting Tailscale..."
tailscale up

# Get IP
TAILSCALE_IP=$(tailscale ip 2>/dev/null)

if [ -n "$TAILSCALE_IP" ]; then
    echo ""
    echo "✅ Tailscale connected!"
    echo "🔗 Your Tailscale IP: $TAILSCALE_IP"
    echo ""
    echo "📝 Update env file with this IP:"
    echo "   nano env"
    echo "   TAILSCALE_IP=\"$TAILSCALE_IP\""
else
    echo ""
    echo "⚠️ Tailscale not connected. Please run:"
    echo "   tailscale up"
fi

echo ""
echo "========================================="
