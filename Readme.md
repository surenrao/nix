# Nix Darwin System Configuration

A modular nix-darwin configuration for macOS using flakes, designed for MacBook Pro M4 Max.

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design, module organization, and configuration flow
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to add packages, modify settings, and maintain the configuration
- **[UPDATE_STRATEGY.md](UPDATE_STRATEGY.md)** - Dependency update process and rollback strategies
- **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - Comprehensive validation checklist after changes
- **[HOME_MANAGER_SETUP.md](HOME_MANAGER_SETUP.md)** - Home Manager standalone setup guide

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
- **Terminal**: Neovim, Tmux
- **Development**: Visual Studio Code, .NET SDK 10, devenv
- **Containers**: Docker, Docker Compose, Colima
- **AI Development**: Aider Chat (AI pair programming)
- **Utilities**: playwright, mkalias

### GUI Applications (via Homebrew)
- **Automation**: Hammerspoon
- **Media**: IINA video player
- **Utilities**: The Unarchiver, PearCleaner
- **Productivity**: Maccy (clipboard), Itsycal (calendar)
- **Creative**: Inkscape (vector graphics editor)

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

For detailed guidance on modifying this configuration, see **[CONTRIBUTING.md](CONTRIBUTING.md)**.

### Quick Reference: Where to Add Packages

**Decision Tree:**
- **GUI Application?** → Add to [`modules/homebrew.nix`](modules/homebrew.nix) (casks)
- **System-wide CLI tool?** → Add to [`modules/packages.nix`](modules/packages.nix)
- **User-specific tool?** → Add to [`modules/home.nix`](modules/home.nix)
- **Development-only tool?** → Add to `devenv.nix`

### Package Management Strategy

This configuration follows a **single source of truth** philosophy:
- **Nix** manages all CLI tools for reproducibility
- **Homebrew** manages GUI applications for better macOS integration
- **No duplicates** across different package managers

See **[ARCHITECTURE.md](ARCHITECTURE.md)** for the complete package management philosophy.

### Modifying System Preferences
Edit [`modules/system-defaults.nix`](modules/system-defaults.nix) to customize macOS settings.

For available options, see: [Nix Darwin System Defaults](https://mynixos.com/nix-darwin/options/system.defaults)

## ⚡ Automatic Environment Activation (direnv + devenv)

The development environment configured in `devenv.nix` (.NET 10, Node.js 24, Python 3 + uv) is automatically activated whenever you open a terminal or launch an editor in either `~/nix` or any project inside `~/Projects`.

### How It Works

1. **`direnv` with `nix-direnv`**:
   Managed declaratively in [`modules/home.nix`](modules/home.nix) under `programs.direnv`. Automatically hooked into Zsh (`~/.zshrc`).
2. **Current Directory (`~/nix`)**:
   Contains `~/nix/.envrc` (`use devenv`). Entering `~/nix` automatically activates the environment defined in `devenv.nix`.
3. **Projects Directory (`~/Projects`)**:
   Contains `~/Projects/.envrc` with `source_env ~/nix/.envrc`. Every project folder under `~/Projects/` (e.g. `kosha-app`, `the-disgraced-prince`, etc.) automatically inherits the complete development environment without needing separate configuration.
4. **Instant & Cached**:
   Environment evaluations are cached by `direnv`, taking ~0.5s when entering directories.
5. **Clean Exit**:
   Exiting `~/nix` or `~/Projects` automatically unloads the variables and paths from your shell.

### Per-Project Overrides

If a specific project requires its own distinct tools or versions in the future:
1. Create a `devenv.nix` and `.envrc` inside that project folder:
   ```bash
   echo "use devenv" > ~/Projects/<project-name>/.envrc
   direnv allow ~/Projects/<project-name>
   ```
2. Direnv will use that project's local environment instead of the parent `~/Projects` default.

## 🐍 Development Environment & Languages

### Included in `devenv.nix`:
- **.NET SDK 10**: Fully configured with `DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1` for macOS.
- **Node.js**: Modern JavaScript/TypeScript runtime.
- **Python 3 & uv**: High-performance Python project management.
- **Pre-configured Scripts**:
  - `devenv tasks run test` or `uv run pytest`
  - `format`: Code formatting with Black
  - `lint`: Code linting with Flake8



## 🧪 Testing Changes

After modifying the configuration, follow this workflow:

```bash
# 1. Check syntax
nix flake check

# 2. Build without applying (dry-run)
darwin-rebuild build --flake ~/nix#m4max

# 3. Apply if successful
./rebuild-system.sh

# 4. Verify changes
# Test packages, settings, applications
```

For comprehensive testing, see **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)**.

## 🔍 Troubleshooting

### Common Issues

**Build Errors**
```bash
# Check for syntax errors
nix flake check

# Show detailed error trace
darwin-rebuild switch --flake ~/nix#m4max --show-trace
```

**Package Not Found**
```bash
# Search nixpkgs
nix search nixpkgs <package-name>

# If not in nixpkgs, check Homebrew
brew search <package-name>
```

**Applications Not in Spotlight**
The system automatically handles Spotlight integration, but if apps don't appear:
```bash
# Force Spotlight reindex
sudo mdutil -E /Applications

# Re-register with Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
```

### Rollback Changes

If something goes wrong, you have multiple rollback options:

**Option 1: Nix Generations**
```bash
# List available generations
darwin-rebuild --list-generations
home-manager generations

# Rollback to previous generation
sudo darwin-rebuild --rollback
home-manager switch --rollback
```

**Option 2: Git History**
```bash
# View recent changes
git log --oneline -10

# Restore specific file
git checkout HEAD~1 <file>

# Rebuild with restored configuration
./rebuild-system.sh
```

For more troubleshooting scenarios, see **[CONTRIBUTING.md](CONTRIBUTING.md)**.

## 📚 References

### External Resources
- [Nix Darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Nix Darwin Options Reference](https://mynixos.com/nix-darwin/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix Package Search](https://search.nixos.org/packages)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [devenv Documentation](https://devenv.sh)

### Internal Documentation
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System design and module organization
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines and workflows
- **[UPDATE_STRATEGY.md](UPDATE_STRATEGY.md)** - Dependency update process
- **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)** - Validation checklist

## 🤝 Contributing

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for detailed contribution guidelines, including:
- Decision trees for where to add packages
- Testing workflows
- Code style guidelines
- Git commit conventions
- Common pitfalls to avoid

## 📄 License

This configuration is provided as-is for educational and personal use.
