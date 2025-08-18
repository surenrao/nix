# Nix Darwin System Configuration

A modular nix-darwin configuration for macOS using flakes, designed for MacBook Pro M4 Max.

## 📁 Project Structure

```
.
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Pinned dependency versions
├── rebuild-system.sh            # Unified rebuild script
├── modules/                     # Modular configuration files
│   ├── applications.nix         # App linking & Spotlight integration
│   ├── homebrew.nix            # Homebrew packages & casks
│   ├── home.nix                # Home Manager user configuration
│   ├── nix-config.nix          # Nix daemon settings
│   ├── packages.nix            # System packages
│   ├── security.nix            # Security & authentication
│   ├── system-defaults.nix     # macOS system preferences
│   └── user.nix                # User configuration & environment variables
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

# Apply the configuration (unified rebuild)
./rebuild-system.sh
```

## 🔧 Usage

### Unified Rebuild (Recommended)
Apply both nix-darwin and Home Manager configurations:
```bash
./rebuild-system.sh
```
This single command rebuilds both system and user configurations.

### Individual Rebuilds
**System configuration only:**
```bash
sudo darwin-rebuild switch --flake ~/nix#m4max
```

**User configuration only:**
```bash
home-manager switch
```

### Building the Configuration
Test your configuration changes without applying them:
```bash
darwin-rebuild build --flake ~/nix#m4max
```

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
- **Development**: Visual Studio Code, Python 3.13.5 (with pip & virtualenv)
- **Containers**: Docker, Docker Compose, Colima
- **AI Development**: Aider Chat (AI pair programming), Ollama (local AI model runner)

### GUI Applications (via Homebrew)
- **Automation**: Hammerspoon
- **Media**: IINA video player
- **Utilities**: The Unarchiver, PearCleaner
- **Productivity**: Maccy (clipboard), Itsycal (calendar)

### Mac App Store Apps
- Windows App (Microsoft Remote Desktop)
- Xcode

### System Configurations
- **macOS Defaults**: Dark mode, Finder preferences, Dock settings
- **Security**: Touch ID for sudo, guest user disabled
- **Applications**: Spotlight integration for Nix apps

### User Packages (via Home Manager)
- **Development Tools**: Git, GitHub CLI, jq, yq, curl, wget
- **Shell Utilities**: bat, eza, fd, ripgrep, fzf, zoxide
- **System Monitoring**: htop, btop
- **Python Tools**: pip, virtualenv (user-level)
- **Fonts**: Nerd Fonts (FiraCode, JetBrains Mono)

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
- System-wide environment variables

### User Environment (Home Manager)
Edit [`modules/home.nix`](modules/home.nix) for:
- User-specific packages and tools
- Shell configuration and aliases
- Git settings and dotfiles
- Development environment setup

## 🐍 Python Development

### Available Tools
- **Python 3.13.5** with full development tools
- **pip 25.0.1** for package management
- **virtualenv 20.31.2** for isolated environments
- **devenv** for declarative development environments

### Usage Examples
```bash
# Check versions
python3 --version
pip --version
virtualenv --version

# Create virtual environment
virtualenv myproject
source myproject/bin/activate

# Install packages
pip install requests numpy pandas
```

### Using devenv for Python Development

This configuration includes devenv.sh for creating reproducible development environments.

#### Entering the Python Development Environment
```bash
# Enter the default development shell
nix develop

# Or explicitly use the devenv shell
nix develop .#default
```

#### Features of the Python devenv Environment
- Pre-configured Python 3 environment
- Automatic virtual environment creation
- Pre-commit hooks for code quality (black, flake8)
- Helpful scripts for common tasks:
  - `test`: Run tests with pytest
  - `format`: Format code with black
  - `lint`: Lint code with flake8

#### Customizing the Python Environment
The devenv configuration is defined in `devenv.nix`. You can modify this file to:
- Add additional Python packages
- Configure environment variables
- Add custom scripts
- Set up pre-commit hooks

After making changes to `devenv.nix`, rebuild the environment with:
```bash
nix develop
```


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
