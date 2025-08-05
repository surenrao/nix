#!/bin/bash

# Unified System Rebuild Script
# Applies both nix-darwin and home-manager configurations

set -e  # Exit on any error

echo "🔄 Rebuilding nix-darwin system configuration..."
sudo darwin-rebuild switch --flake ~/nix#m4max

echo ""
echo "🏠 Applying home-manager configuration..."
home-manager switch

echo ""
echo "✅ System rebuild complete!"
echo "   - nix-darwin: System packages and settings applied"
echo "   - home-manager: User packages and configurations applied"