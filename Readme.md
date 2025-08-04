# Nix Darwin System Configuration

A modular nix-darwin configuration for macOS using flakes, designed for MacBook Pro M4 Max.

## 📁 Project Structure

```
.
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Pinned dependency versions
├── modules/                     # Modular configuration files
│   ├── applications.nix         # App linking & Spotlight integration
│   ├── homebrew.nix            # Homebrew packages & casks
│   ├── home.nix                # Home Manager user configuration
│   ├── nix-config.nix          # Nix daemon settings
│   ├── packages.nix            # System packages
│   ├── security.nix            # Security & authentication
│   ├── system-defaults.nix     # macOS system preferences
│   └── user.nix                # User configuration
├── HOME_MANAGER_SETUP.md       # Home Manager documentation
└── README.md                   # This file
```

## 🚀 Quick Start

### Prerequisites
- macOS (Apple Silicon recommended)
- Nix package manager installed
- Git repository cloned to `~/nix`

### Initial Setup
```bash
# Clone this repository
git clone <repository-url> ~/nix
cd ~/nix

# Apply the configuration
sudo darwin-rebuild switch --flake ~/nix#m4max
```

## 🔧 Usage

### Building the Configuration
Test your configuration changes without applying them:
```bash
darwin-rebuild build --flake ~/nix#m4max
```

### Applying Changes
Apply the configuration to your system:
```bash
sudo darwin-rebuild switch --flake ~/nix#m4max
```
> **Note**: `sudo` is required for system-level changes

### Updating to Latest Versions

#### Update All Dependencies
Update all flake inputs to their latest versions:
```bash
nix flake update
```

#### Update Specific Input
Update only a specific input (e.g., nixpkgs):
```bash
nix flake update nixpkgs
```

#### Update and Apply
Update dependencies and apply changes in one command:
```bash
nix flake update && sudo darwin-rebuild switch --flake ~/nix#m4max
```

## 📦 What's Included

### System Packages (via Nix)
- **Terminal**: Alacritty, Neovim, Tmux
- **Development**: Visual Studio Code
- **Containers**: Docker, Docker Compose, Colima

### GUI Applications (via Homebrew)
- **Automation**: Hammerspoon
- **Media**: IINA video player
- **Utilities**: The Unarchiver, PearCleaner
- **Productivity**: Maccy (clipboard), Itsycal (calendar)
- **AI**: LM Studio

### Mac App Store Apps
- Windows App (Microsoft Remote Desktop)
- Xcode

### System Configurations
- **macOS Defaults**: Dark mode, Finder preferences, Dock settings
- **Security**: Touch ID for sudo, guest user disabled
- **Applications**: Spotlight integration for Nix apps

## 🛠️ Customization

### Adding New Packages
1. **Nix packages**: Edit [`modules/packages.nix`](modules/packages.nix)
2. **Homebrew casks**: Edit [`modules/homebrew.nix`](modules/homebrew.nix)
3. **Mac App Store**: Add to `masApps` in [`modules/homebrew.nix`](modules/homebrew.nix)

### Modifying System Preferences
Edit [`modules/system-defaults.nix`](modules/system-defaults.nix) to customize:
- Dock behavior and persistent apps
- Finder settings
- Control Center preferences
- Custom application preferences

### User Settings
Edit [`modules/user.nix`](modules/user.nix) for:
- Primary user configuration
- Shell preferences
- Git settings (currently commented out)

## 🔍 Troubleshooting

### Common Issues

**Build Errors**
```bash
# Check for syntax errors
nix flake check

# Show detailed error trace
darwin-rebuild switch --flake ~/nix#m4max --show-trace
```

**Git Tree Dirty Warning**
```bash
# Add new files to git
git add .

# Or commit changes
git commit -m "Update configuration"
```

**Applications Not in Spotlight**
The system automatically handles Spotlight integration, but if apps don't appear:
```bash
# Force Spotlight reindex
sudo mdutil -E /Applications
```

### Rollback Changes
If something goes wrong, rollback to previous generation:
```bash
# List available generations
sudo darwin-rebuild --list-generations

# Rollback to previous generation
sudo darwin-rebuild --rollback
```

## 📚 References

- [Nix Darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [macOS System Defaults](https://mynixos.com/nix-darwin/options/system.defaults)
- [Homebrew Integration](https://github.com/zhaofengli-wip/nix-homebrew)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes in the appropriate module
4. Test with `darwin-rebuild build`
5. Submit a pull request

## 📄 License

This configuration is provided as-is for educational and personal use.
