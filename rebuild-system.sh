#!/bin/bash

# Unified System Rebuild Script
# Applies both nix-darwin and home-manager configurations

set -e  # Exit on any error

# Handle existing /etc/hosts file if not managed by Nix
if [ -f /etc/hosts ] && [ ! -L /etc/hosts ]; then
  echo "🚨 Found existing /etc/hosts file not managed by Nix. Renaming to /etc/hosts.before-nix-darwin"
  sudo mv /etc/hosts /etc/hosts.before-nix-darwin
fi

echo "🔄 Rebuilding nix-darwin system configuration..."
sudo darwin-rebuild switch --flake ~/nix#m4max

# Apply custom /etc/hosts content
echo ""
echo "📝 Applying custom /etc/hosts entries..."
sudo tee /etc/hosts > /dev/null <<EOF
##
# Host Database
#
# localhost is used to configure the loopback interface
# when the system is booting.  Do not change this entry.
##
127.0.0.1       localhost
255.255.255.255 broadcasthost
::1             localhost
192.0.2.10 gitea.home.example proget.home.example truenas.home.example
EOF
echo "✅ Custom /etc/hosts entries applied."

echo ""
echo "🏠 Applying home-manager configuration..."
home-manager switch

echo ""
echo "✅ System rebuild complete!"
echo "   - nix-darwin: System packages and settings applied"
echo "   - home-manager: User packages and configurations applied"