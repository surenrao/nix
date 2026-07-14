#!/bin/bash

# Unified System Update Script
# Updates flake inputs and rebuilds the system

set -e  # Exit on any error

echo "🔄 Updating flake inputs..."
nix flake update

echo ""
echo "🛠️ Rebuilding the system with the latest updates..."
./rebuild-system.sh

echo ""
echo "✅ System update complete!"
