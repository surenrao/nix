# Nix Configuration Architecture

## Overview

This document explains the modular architecture of this nix-darwin configuration for macOS (Apple Silicon M4 Max). The configuration manages both system-level and user-level settings declaratively using Nix flakes.

## Project Structure

```
~/nix/
├── flake.nix                      # Main entry point, orchestrates everything
├── flake.lock                     # Locked dependency versions
├── rebuild-system.sh              # Unified rebuild script
├── devenv.nix                     # Development environment (Python/Node.js)
├── modules/
│   ├── packages.nix               # System packages via Nix
│   ├── homebrew.nix               # GUI apps & Homebrew integration
│   ├── home.nix                   # Home Manager user configuration
│   ├── system-defaults.nix        # macOS system preferences
│   ├── applications.nix           # App linking for Spotlight
│   ├── security.nix               # Security & authentication
│   ├── nix-config.nix            # Nix daemon settings
│   └── user.nix                   # System user configuration
└── docs/
    ├── README.md                  # Main documentation
    ├── ARCHITECTURE.md            # This file
    ├── CONTRIBUTING.md            # How to modify configuration
    ├── UPDATE_STRATEGY.md         # Dependency update guide
    └── TESTING_CHECKLIST.md       # Validation checklist
```

## Configuration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                         flake.nix                            │
│                    (Entry Point)                             │
└──────────────┬──────────────────────────────────────────────┘
               │
               ├─────────────────┬─────────────────┬──────────┐
               ▼                 ▼                 ▼          ▼
       ┌──────────────┐  ┌──────────────┐  ┌──────────┐  External
       │ System Config│  │ User Config  │  │ Dev Env  │  Modules
       │ (nix-darwin) │  │(Home Manager)│  │ (devenv) │  ────────
       └──────┬───────┘  └──────┬───────┘  └────────┬─┘  • mac-app-util
              │                 │                    │    • nix-homebrew
   ┌──────────┼─────────────────┴────────────────┐  │
   │          │                                   │  │
   ▼          ▼          ▼         ▼        ▼    ▼  ▼
packages  homebrew  system-   applications security user
 .nix      .nix    defaults.nix  .nix      .nix  .nix
                   nix-config.nix
```

## Module Responsibilities

### System Configuration (nix-darwin)

#### packages.nix
**Purpose**: System-wide packages installed via Nix

**What it manages**:
- Terminal tools (neovim, tmux)
- Development environments (vscode, devenv)
- Programming runtimes (.NET SDK 10)
- Container tools (docker, docker-compose, colima)
- System utilities (playwright, mkalias)
- AI development tools (aider-chat)

**When to use**: Add packages here if they:
- Need to be available system-wide
- Require system-level integration
- Are development tools needed by multiple users

**Location**: Installed to `/run/current-system/sw/bin`

#### homebrew.nix
**Purpose**: Homebrew integration for GUI apps and Mac App Store

**What it manages**:
- **Casks**: GUI applications (hammerspoon, iina, pearcleaner, maccy, itsycal)
- **MAS Apps**: Mac App Store applications (Windows App, Xcode)
- **Brews**: CLI tools NOT available in nixpkgs (currently only `mas`)

**When to use**: Add applications here if they:
- Are GUI applications
- Come from Mac App Store
- Have better macOS integration via Homebrew
- Are not available in nixpkgs

**Configuration**:
```nix
onActivation = {
  cleanup = "zap";        # Remove unlisted packages
  autoUpdate = true;      # Auto-update Homebrew
  upgrade = true;         # Auto-upgrade packages
};
```

#### system-defaults.nix
**Purpose**: macOS system preferences (equivalent to `defaults write`)

**What it manages**:
- Dock settings (autohide, persistent apps)
- Finder preferences (view style, show extensions)
- Control Center settings (battery percentage)
- Login window (disable guest user)
- Global domain settings (dark mode, file extensions)
- Custom app preferences (WebKit, screenshots, printing)

**When to use**: Modify settings here to:
- Change macOS system behavior
- Configure built-in macOS apps
- Set system-wide preferences

**Reference**: [mynixos.com/nix-darwin/options/system.defaults](https://mynixos.com/nix-darwin/options/system.defaults)

#### applications.nix
**Purpose**: Link Nix-installed applications to macOS Spotlight and Launchpad

**What it manages**:
- Creates `/Applications/Nix Apps/` directory
- Symlinks applications using `mkalias`
- Registers apps with Spotlight (mdimport)
- Registers apps with Launch Services (lsregister)

**Why needed**: Nix apps install to `/nix/store` which macOS doesn't index. This module makes them discoverable via Spotlight (Cmd+Space).

**Automatic**: No manual configuration needed - automatically processes all GUI apps from packages.nix

#### security.nix
**Purpose**: Security and authentication settings

**What it manages**:
- Touch ID for sudo authentication
- Guest user settings (disabled)
- Screen saver security (commented out, can be enabled)

**When to use**: Modify here to:
- Enable/disable Touch ID for sudo
- Configure authentication requirements
- Set security policies

#### nix-config.nix
**Purpose**: Nix daemon configuration

**What it manages**:
- Experimental features (flakes, nix-command)
- Platform support (aarch64-darwin, x86_64-darwin)
- State version (25.11)

**When to use**: Rarely modified - only for Nix daemon settings

#### user.nix
**Purpose**: System user configuration

**What it manages**:
- Primary system user (`surenrao`)
- User-level system settings

**When to use**: Rarely modified - mainly for initial setup

### User Configuration (Home Manager)

#### home.nix
**Purpose**: User-specific packages and dotfile management

**What it manages**:
- **User packages**: Development tools, shell utilities
  - Development: git, gh, jq, yq, curl, wget
  - Python: pip, virtualenv
  - Shell utilities: bat, eza, fd, ripgrep, fzf, zoxide
  - System monitoring: htop, btop
  - Text processing: tree
  - Fonts: Nerd Fonts (Fira Code, JetBrains Mono)

- **Environment variables**:
  - `EDITOR=nvim`
  - `BROWSER=open`
  - `PYTHONPATH` (dynamically set to current Python version)
  - `PIP_USER=1`
  - OLLAMA configuration variables

- **Program configurations**:
  - Git (user name, email, branch defaults)
  - Bash shell
  - Starship prompt (custom symbols)
  - Zoxide (smart cd)
  - Fzf (fuzzy finder with Fish integration)
  - Bat (syntax-highlighted cat with TwoDark theme)

**When to use**: Add packages/config here if they:
- Are user-specific tools
- Don't need system-wide availability
- Include per-user configuration

**Standalone**: Home Manager runs independently from nix-darwin. Apply changes with `home-manager switch`.

**State**: `home.stateVersion = "25.05"` - don't change without reading release notes

### Development Environment

#### devenv.nix
**Purpose**: Project-specific development environment

**What it manages**:
- **Languages**: Python 3, Node.js/JavaScript
- **Tools**: black, flake8, pytest
- **Git hooks**: Pre-commit hooks for formatting/linting
- **Scripts**: test, format, lint helper commands
- **Virtual environments**: Automatic .venv creation

**When to use**:
- Enter with `devenv shell`
- Automatically activates Python virtual environment
- Ideal for project-specific development work

**Not**: This is separate from system/user packages - only active in devenv shell

## Package Management Philosophy

### Decision Framework: Nix vs Homebrew

```
Is it a GUI application?
├─ YES → Homebrew (homebrew.nix - casks)
└─ NO → Is it available in nixpkgs?
    ├─ YES → Nix (packages.nix or home.nix)
    └─ NO → Homebrew (homebrew.nix - brews)

If available in both:
├─ Prefer Nix for CLI tools (better reproducibility)
└─ Prefer Homebrew for GUI apps (better macOS integration)
```

### Current Strategy

**Nix manages**:
- All CLI development tools
- Programming language runtimes (.NET, Node.js via devenv)
- Terminal utilities
- Text editors and development environments
- Container tools

**Homebrew manages**:
- GUI applications (IINA, Hammerspoon, etc.)
- Mac App Store applications
- `mas` CLI tool (not in nixpkgs)

**Why this split**:
1. **Reproducibility**: Nix provides exact version control for development tools
2. **Integration**: Homebrew handles macOS-specific GUI app integration better
3. **Simplicity**: Single source of truth for each tool category
4. **Performance**: Avoids duplicate downloads and installations

### Layer Separation

```
┌─────────────────────────────────────────────────────────┐
│  User Layer (Home Manager)                              │
│  - User packages and dotfiles                           │
│  - Shell configuration                                  │
│  - Per-user environment variables                       │
│  - Applied with: home-manager switch                    │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┼──────────────────────────────┐
│  System Layer (nix-darwin)                              │
│  - System packages                                      │
│  - macOS preferences                                    │
│  - System-wide settings                                 │
│  - Applied with: darwin-rebuild switch                  │
└─────────────────────────────────────────────────────────┘
                           ▲
                           │
┌──────────────────────────┼──────────────────────────────┐
│  Development Layer (devenv)                             │
│  - Project-specific tools                               │
│  - Language runtimes                                    │
│  - Git hooks                                            │
│  - Activated with: devenv shell                         │
└─────────────────────────────────────────────────────────┘
```

## Rebuild Process

### Full System Update
```bash
./rebuild-system.sh
```
Executes:
1. `sudo darwin-rebuild switch --flake ~/nix#m4max` (system)
2. `home-manager switch` (user)

### System Only
```bash
sudo darwin-rebuild switch --flake ~/nix#m4max
```

### User Only
```bash
home-manager switch
```

### Build Without Applying (dry-run)
```bash
darwin-rebuild build --flake ~/nix#m4max
```

## State Management

### System State
- **Location**: `/run/current-system`
- **Managed by**: nix-darwin
- **Version**: Tracked in `nix-config.nix` (`system.stateVersion`)
- **Generations**: `darwin-rebuild --list-generations`

### User State
- **Location**: `~/.local/state/home-manager`
- **Managed by**: Home Manager
- **Version**: Tracked in `home.nix` (`home.stateVersion`)
- **Generations**: `home-manager generations`

### Rollback
```bash
# System rollback
sudo darwin-rebuild --rollback

# User rollback
home-manager switch --rollback

# Specific generation
darwin-rebuild --list-generations
sudo darwin-rebuild switch --switch-generation <number>
```

## Dependencies

### Flake Inputs
```nix
inputs = {
  nixpkgs          # Nix package repository
  nix-darwin       # macOS system management
  nix-homebrew     # Homebrew integration
  mac-app-util     # Application linking utilities
  devenv           # Development environments
  flake-utils      # Flake utilities
}
```

### Module Dependencies

```
nix-config.nix (base Nix settings)
    ├── user.nix (system user)
    ├── packages.nix (system packages)
    │   └── applications.nix (links apps from packages)
    ├── homebrew.nix (brew packages & casks)
    ├── system-defaults.nix (macOS preferences)
    └── security.nix (auth & security)

home.nix (independent - Home Manager)
    └── Uses packages from system layer
```

## Extension Guide

### Adding a System Package
1. Edit `modules/packages.nix`
2. Add to `environment.systemPackages`
3. Run `./rebuild-system.sh`

Example:
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...
  your-new-package  # Add here with comment
];
```

### Adding a GUI Application
1. Edit `modules/homebrew.nix`
2. Add to `casks` or `masApps`
3. Run `./rebuild-system.sh`

Example:
```nix
casks = [
  # ... existing casks ...
  "your-new-app"  # Homebrew cask name
];
```

### Adding a User Package
1. Edit `modules/home.nix`
2. Add to `home.packages`
3. Run `home-manager switch` or `./rebuild-system.sh`

Example:
```nix
home.packages = with pkgs; [
  # ... existing packages ...
  your-user-tool
];
```

### Modifying macOS Settings
1. Edit `modules/system-defaults.nix`
2. Add setting with comment
3. Run `sudo darwin-rebuild switch --flake ~/nix#m4max`

Example:
```nix
system.defaults = {
  dock = {
    autohide = true;
    your-new-setting = value;  # Explanation of what it does
  };
};
```

## Best Practices

1. **Single Source of Truth**: Each package should be defined in exactly ONE location
2. **Comments**: Always add comments explaining non-obvious settings
3. **Testing**: Build before applying (`darwin-rebuild build`)
4. **Commits**: Use conventional commits for changes
5. **Backups**: Git is your backup - commit working states
6. **Documentation**: Update this file when adding new patterns

## Troubleshooting

### Build Fails
```bash
# Check syntax
nix flake check

# Show detailed trace
darwin-rebuild switch --flake ~/nix#m4max --show-trace
```

### Package Not Found
```bash
# Search nixpkgs
nix search nixpkgs <package-name>

# If not in nixpkgs, use Homebrew
```

### Spotlight Not Finding Apps
```bash
# Force reindex
sudo mdutil -E /Applications

# Re-register with Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
```

### Configuration Conflicts
- Check for duplicate package definitions across modules
- Ensure only one module manages each setting
- Review git diff to see what changed

## Platform Notes

### Apple Silicon (M4 Max)
- **Architecture**: `aarch64-darwin`
- **Rosetta 2**: Enabled via `enableRosetta = true` in homebrew config
- **Cross-compilation**: Supports x86_64-darwin packages via Rosetta

### Nix Store
- **Location**: `/nix/store`
- **Read-only**: Never modify directly
- **Garbage collection**: `nix-collect-garbage -d` to clean old generations

## References

- [Nix Darwin Options](https://mynixos.com/nix-darwin/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.xhtml)
- [Nix Package Search](https://search.nixos.org/packages)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [devenv Documentation](https://devenv.sh)
