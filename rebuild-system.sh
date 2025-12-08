#!/bin/bash

# Unified System Rebuild Script
# Applies both nix-darwin and home-manager configurations

set -e  # Exit on any error

# Handle existing /etc/hosts file if not managed by Nix
if [ -f /etc/hosts ] && [ ! -L /etc/hosts ]; then
  echo "🚨 Moving existing /etc/hosts to /etc/hosts.before-nix-darwin"
  sudo mv /etc/hosts /etc/hosts.before-nix-darwin
fi

echo "🔄 Rebuilding nix-darwin system configuration..."
sudo darwin-rebuild switch --flake ~/nix#m4max

echo ""
echo "🏠 Applying home-manager configuration..."
home-manager switch

echo ""
echo "✅ System rebuild complete!"
echo "   - nix-darwin: System packages and settings applied"
echo "   - home-manager: User packages and configurations applied"