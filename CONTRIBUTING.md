# Contributing to Nix Configuration

This document provides guidelines for maintaining and extending this nix-darwin configuration.

## Table of Contents

- [Before You Start](#before-you-start)
- [Adding Packages](#adding-packages)
- [Modifying System Settings](#modifying-system-settings)
- [Testing Changes](#testing-changes)
- [Git Workflow](#git-workflow)
- [Code Style](#code-style)
- [Common Pitfalls](#common-pitfalls)
- [Getting Help](#getting-help)

## Before You Start

### Prerequisites

1. **Understand the Architecture**: Read [ARCHITECTURE.md](ARCHITECTURE.md) to understand module organization
2. **Backup**: Create a safety tag: `git tag backup-$(date +%Y%m%d)`
3. **Clean State**: Ensure `git status` is clean or only has intended changes

### Quick Reference

```bash
# Test configuration (dry-run)
darwin-rebuild build --flake ~/nix#m4max

# Apply changes
./rebuild-system.sh

# Rollback if needed
sudo darwin-rebuild --rollback
```

## Adding Packages

### Decision Tree: Where to Add?

```
┌─────────────────────────────────────────┐
│ Is it a GUI application?                │
├─────────────────────────────────────────┤
│ YES → modules/homebrew.nix (casks)      │
│                                         │
│ NO ↓                                    │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│ Is it needed system-wide?               │
├─────────────────────────────────────────┤
│ YES → modules/packages.nix              │
│                                         │
│ NO ↓                                    │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│ Is it user-specific?                    │
├─────────────────────────────────────────┤
│ YES → modules/home.nix                  │
│                                         │
│ NO ↓                                    │
└─────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────┐
│ Is it for development only?             │
├─────────────────────────────────────────┤
│ YES → devenv.nix                        │
└─────────────────────────────────────────┘
```

### System Packages (modules/packages.nix)

**When to use**:
- System-wide CLI tools
- Development environments
- Tools needed by all users
- System-level utilities

**How to add**:

1. Search for the package:
```bash
nix search nixpkgs <package-name>
```

2. Add to `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  # ... existing packages ...

  # Category Comment (e.g., "Database Tools")
  your-package    # Brief description of what it does
];
```

3. Test and apply:
```bash
darwin-rebuild build --flake ~/nix#m4max
./rebuild-system.sh
```

**Example**:
```nix
environment.systemPackages = with pkgs; [
  # Development Tools
  neovim          # Modern Vim-based text editor
  vscode          # Visual Studio Code editor
  dotnet-sdk_10   # .NET SDK 10 (latest)
  postgresql      # PostgreSQL database  # NEW
];
```

### Homebrew Applications (modules/homebrew.nix)

**When to use**:
- GUI applications
- Mac App Store apps
- Tools NOT available in nixpkgs
- Apps that need better macOS integration

**How to add**:

#### GUI Applications (Casks)

1. Find cask name:
```bash
brew search <app-name>
```

2. Add to `casks`:
```nix
casks = [
  # ... existing casks ...
  "your-app-name"  # Application description
];
```

#### Mac App Store Applications

1. Find app ID (from App Store URL or `mas search <app-name>`):
```bash
mas search "App Name"
```

2. Add to `masApps`:
```nix
masApps = {
  # ... existing apps ...
  "App Name" = 123456789;  # App Store ID
};
```

#### CLI Tools (Brews)

**IMPORTANT**: Only add CLI tools here if they're NOT available in nixpkgs.

```nix
brews = [
  "mas"           # Mac App Store CLI (not in nixpkgs)
  # Add only if NOT in nixpkgs
];
```

**Example**:
```nix
# GUI Applications
casks = [
  "hammerspoon"   # Desktop automation scripting
  "iina"          # Modern media player
  "docker"        # Docker Desktop for Mac  # NEW
];

# Mac App Store
masApps = {
  "Windows App" = 1295203466;
  "Xcode" = 497799835;
  "Keynote" = 409183694;  # NEW
};
```

### User Packages (modules/home.nix)

**When to use**:
- User-specific tools
- Shell utilities
- Personal development tools
- Dotfile management

**How to add**:

```nix
home.packages = with pkgs; [
  # ... existing packages ...

  # Category
  your-tool    # What it does
];
```

**Example**:
```nix
home.packages = with pkgs; [
  # Development Tools
  git
  gh

  # Shell Utilities
  bat
  eza

  # New additions
  jless       # JSON viewer  # NEW
  delta       # Git diff tool  # NEW
];
```

### Development Environment (devenv.nix)

**When to use**:
- Project-specific dependencies
- Language runtimes for development
- Tools only needed in dev shell

**How to add**:

```nix
packages = with pkgs; [
  # ... existing packages ...
  your-dev-tool
];
```

**Example**:
```nix
packages = with pkgs; [
  python3
  nodejs
  rustc  # NEW: Rust compiler
  cargo  # NEW: Rust package manager
];
```

## Modifying System Settings

### macOS Preferences (modules/system-defaults.nix)

**Reference**: [mynixos.com/nix-darwin/options/system.defaults](https://mynixos.com/nix-darwin/options/system.defaults)

**How to modify**:

1. Find the setting you want to change in the reference docs
2. Add to appropriate section with a comment
3. Test and apply

**Example**:
```nix
system.defaults = {
  dock = {
    autohide = true;
    show-recents = false;  # NEW: Hide recent applications
  };

  finder = {
    FXPreferredViewStyle = "clmv";  # Column view
    AppleShowAllFiles = true;       # NEW: Show hidden files
  };
};
```

### Adding Apps to Dock

**IMPORTANT**: Apps must be installed in packages.nix or homebrew.nix first!

```nix
dock = {
  persistent-apps = [
    "/System/Applications/System Settings.app"
    "/Applications/YourNewApp.app"  # NEW: Must exist
  ];
};
```

## Testing Changes

### Recommended Workflow

```bash
# 1. Check syntax
nix flake check

# 2. Build without applying (dry-run)
darwin-rebuild build --flake ~/nix#m4max

# 3. Review what will change
# Look for warnings/errors in output

# 4. Apply changes
./rebuild-system.sh

# 5. Verify functionality
# Test the packages/settings you added

# 6. Rollback if needed
sudo darwin-rebuild --rollback
home-manager switch --rollback
```

### Validation Checklist

After applying changes:

- [ ] Configuration builds successfully
- [ ] No error messages during activation
- [ ] New packages are accessible (`which <package>`)
- [ ] GUI apps appear in Spotlight
- [ ] System settings applied correctly
- [ ] No duplicate packages across modules

See [TESTING_CHECKLIST.md](TESTING_CHECKLIST.md) for comprehensive testing.

## Git Workflow

### Committing Changes

**IMPORTANT**: Only commit when changes work and have been tested!

#### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>: <short description>

[optional longer description]

[optional footer]
```

**Types**:
- `feat`: New feature or package
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring without behavior change
- `chore`: Maintenance tasks
- `update`: Dependency updates

#### Examples

**Good commit messages**:
```
feat: add PostgreSQL to system packages

Added PostgreSQL database server and client tools for local
development work.

fix: remove broken alacritty dock reference

Alacritty was commented out in packages.nix but still
referenced in system-defaults.nix dock configuration.

refactor: eliminate package duplication

Removed 14 CLI tools from Homebrew that were already managed
by Nix for better reproducibility.

update: bump flake inputs to latest versions

Updated nixpkgs, nix-darwin, and other dependencies.
```

**Bad commit messages**:
```
update stuff
fixed things
added packages
wip
```

### Git Commands

```bash
# Stage changes
git add <files>

# Commit with message
git commit -m "feat: add new package"

# View commit history
git log --oneline

# Create safety tag
git tag backup-$(date +%Y%m%d)

# View changes
git diff
git status
```

## Code Style

### Nix Code

#### Formatting

```nix
# Good: Organized, commented, consistent spacing
environment.systemPackages = with pkgs; [
  # Terminal Tools
  neovim            # Modern Vim-based editor
  tmux              # Terminal multiplexer

  # Development
  vscode            # Visual Studio Code
  dotnet-sdk_10     # .NET SDK 10
];

# Bad: No organization or comments
environment.systemPackages = with pkgs; [
  neovim
vscode
  dotnet-sdk_10
tmux
];
```

#### Comments

**Do**: Explain WHY and WHAT
```nix
autohide = true;  # Auto-hide dock to maximize screen space
```

**Don't**: State the obvious
```nix
autohide = true;  # Sets autohide to true
```

#### Organization

**Categories**: Group related items with section comments
```nix
environment.systemPackages = with pkgs; [
  # Terminal Tools
  neovim
  tmux

  # Development
  vscode
  git
];
```

**Alphabetical**: Within categories, alphabetize when it makes sense
```nix
# Shell Utilities (alphabetical)
bat
eza
fd
ripgrep
zoxide
```

### Module Structure

Keep modules focused:
- One concern per module
- Clear, descriptive file names
- Logical grouping of settings

## Common Pitfalls

### 1. Package Duplication

❌ **DON'T** install the same package in multiple places:

```nix
# packages.nix
environment.systemPackages = [ pkgs.git ];

# home.nix
home.packages = [ pkgs.git ];  # DUPLICATE!

# homebrew.nix
brews = [ "git" ];  # DUPLICATE!
```

✅ **DO** install in ONE appropriate location:

```nix
# home.nix (best for git - has Home Manager config)
home.packages = [ pkgs.git ];

programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "email@example.com";
};
```

### 2. Hardcoded Values

❌ **DON'T** hardcode versions or paths:

```nix
PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages";  # BAD

persistent-apps = [
  "/Users/surenrao/Applications/App.app"  # BAD: hardcoded username
];
```

✅ **DO** use dynamic references:

```nix
PYTHONPATH = "$HOME/.local/lib/python${pkgs.python3.pythonVersion}/site-packages";

persistent-apps = [
  "${pkgs.app}/Applications/App.app"  # Use nix store path
];
```

### 3. Missing Package References

❌ **DON'T** reference packages not installed:

```nix
# system-defaults.nix
persistent-apps = [
  "${pkgs.alacritty}/Applications/Alacritty.app"  # ERROR if not in packages.nix!
];
```

✅ **DO** install first, then reference:

```nix
# Step 1: Add to packages.nix
environment.systemPackages = [ pkgs.alacritty ];

# Step 2: Then reference in system-defaults.nix
persistent-apps = [
  "${pkgs.alacritty}/Applications/Alacritty.app"
];
```

### 4. Uncommenting Without Understanding

❌ **DON'T** uncomment large blocks blindly:

```nix
# Don't uncomment all at once without understanding
# fish = {
#   enable = true;
#   # ... 50 lines of config you haven't reviewed ...
# };
```

✅ **DO** enable features incrementally:

```nix
# Enable fish gradually, test each step
fish = {
  enable = true;
  # Test this works, then add more config
};
```

### 5. Forgetting to Test

❌ **DON'T** skip the build test:

```bash
# DON'T do this
./rebuild-system.sh  # Apply without testing!
```

✅ **DO** test before applying:

```bash
# Build first to check for errors
darwin-rebuild build --flake ~/nix#m4max

# Then apply if successful
./rebuild-system.sh
```

### 6. Not Using Version Control

❌ **DON'T** make changes without commits:

```bash
# Making tons of changes without committing
# Now everything is broken and you don't know what changed!
```

✅ **DO** commit working states:

```bash
# Commit each logical change
git add modules/packages.nix
git commit -m "feat: add postgresql"

# Now you can easily rollback if needed
git revert HEAD
```

## Pull Request Checklist

If sharing this configuration or submitting changes:

- [ ] Configuration builds successfully (`darwin-rebuild build`)
- [ ] No syntax errors (`nix flake check`)
- [ ] No package duplications across modules
- [ ] All changes have comments explaining non-obvious decisions
- [ ] Tested on actual system
- [ ] Git commits follow conventional commit format
- [ ] Updated relevant documentation
- [ ] No hardcoded values (usernames, paths, versions)
- [ ] No secrets or personal information in commits

## Troubleshooting

### Build Errors

```bash
# Show detailed error trace
darwin-rebuild switch --flake ~/nix#m4max --show-trace

# Check for syntax errors
nix flake check

# Verify package exists
nix search nixpkgs <package-name>
```

### Package Not Found

```bash
# Search nixpkgs
nix search nixpkgs <name>

# If not found, check Homebrew
brew search <name>
```

### Application Not in Spotlight

```bash
# Force Spotlight reindex
sudo mdutil -E /Applications

# Re-register with Launch Services
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
```

### Git Conflicts

```bash
# View what changed
git diff

# Discard unwanted changes
git checkout -- <file>

# Restore from previous commit
git checkout HEAD~1 <file>
```

## Getting Help

### Resources

- **Nix Darwin Options**: [mynixos.com/nix-darwin/options](https://mynixos.com/nix-darwin/options)
- **Home Manager Options**: [nix-community.github.io/home-manager/options.xhtml](https://nix-community.github.io/home-manager/options.xhtml)
- **Nix Package Search**: [search.nixos.org/packages](https://search.nixos.org/packages)
- **Nix Flakes Guide**: [nixos.wiki/wiki/Flakes](https://nixos.wiki/wiki/Flakes)
- **devenv Documentation**: [devenv.sh](https://devenv.sh)

### Internal Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)**: System design and module organization
- **[UPDATE_STRATEGY.md](UPDATE_STRATEGY.md)**: How to update dependencies
- **[TESTING_CHECKLIST.md](TESTING_CHECKLIST.md)**: Comprehensive testing guide
- **[README.md](README.md)**: Main documentation and quick start

### Debugging Tips

1. **Check recent changes**: `git log --oneline -10`
2. **Compare with last working state**: `git diff HEAD~1`
3. **View build output carefully**: Error messages often indicate exactly what's wrong
4. **Search for similar issues**: GitHub issues for nix-darwin or nixpkgs
5. **Rollback and retry**: `git checkout HEAD~1 <file>` to undo changes

## Maintenance Schedule

### Weekly
- Review pending changes: `git status`
- Test configuration still builds: `darwin-rebuild build`

### Monthly
- Update dependencies: `nix flake update`
- Clean old generations: `nix-collect-garbage -d`
- Review unused packages

### Quarterly
- Review architecture for improvements
- Update documentation
- Check for deprecated options

## Examples

### Adding a New Development Tool

```bash
# 1. Search for package
nix search nixpkgs ripgrep

# 2. Edit configuration
# Add to modules/home.nix:
# ripgrep  # Better grep

# 3. Test
darwin-rebuild build --flake ~/nix#m4max

# 4. Apply
home-manager switch

# 5. Verify
which rg

# 6. Commit
git add modules/home.nix
git commit -m "feat: add ripgrep for faster searching"
```

### Adding a GUI Application

```bash
# 1. Find Homebrew cask name
brew search visual-studio-code

# 2. Edit configuration
# Add to modules/homebrew.nix casks:
# "visual-studio-code"  # Microsoft VS Code

# 3. Test and apply
darwin-rebuild build --flake ~/nix#m4max
./rebuild-system.sh

# 4. Verify
# Open Spotlight, search for "Visual Studio Code"

# 5. Commit
git add modules/homebrew.nix
git commit -m "feat: add Visual Studio Code via Homebrew"
```

### Changing System Preferences

```bash
# 1. Find setting in docs
# Visit: https://mynixos.com/nix-darwin/options/system.defaults

# 2. Edit modules/system-defaults.nix
# Add setting with comment

# 3. Test
darwin-rebuild build --flake ~/nix#m4max

# 4. Apply
sudo darwin-rebuild switch --flake ~/nix#m4max

# 5. Verify setting in System Preferences

# 6. Commit
git add modules/system-defaults.nix
git commit -m "feat: enable dock autohide"
```
