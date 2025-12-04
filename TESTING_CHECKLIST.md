# Testing Checklist

Use this checklist after making changes to verify everything works correctly.

## Pre-Application Checks

- [ ] Git status clean or shows only expected changes
- [ ] `nix flake check` passes without errors
- [ ] `darwin-rebuild build --flake ~/nix#m4max` succeeds

## System Configuration Tests

### Rebuild Process
- [ ] `sudo darwin-rebuild switch --flake ~/nix#m4max` succeeds
- [ ] No error messages during activation
- [ ] System responsive after rebuild

### macOS System Preferences
- [ ] Dark mode active (if configured)
- [ ] Dock configured properly
  - [ ] Autohide works (if enabled)
  - [ ] No broken app references
  - [ ] Persistent apps appear correctly
- [ ] Finder preferences applied
  - [ ] Shows file extensions
  - [ ] Correct view style
  - [ ] Path bar visible (if enabled)
- [ ] Touch ID works for sudo
- [ ] Screen saver settings correct

## User Configuration Tests

### Home Manager
- [ ] `home-manager switch` succeeds
- [ ] No warnings or errors

### Environment Variables
- [ ] `echo $EDITOR` shows `nvim`
- [ ] `echo $PYTHONPATH` contains correct Python version (not hardcoded 3.11)
- [ ] `echo $BROWSER` shows `open`
- [ ] OLLAMA variables present (if configured)

### Shell Configuration
- [ ] Starship prompt displays correctly
- [ ] Zoxide works (`z <directory>`)
- [ ] Fzf fuzzy finder works (Ctrl+R for history)

## Package Availability

### System Packages (from packages.nix)
- [ ] `nvim --version` works
- [ ] `tmux -V` works
- [ ] `code --version` works (VS Code)
- [ ] `docker --version` works
- [ ] `dotnet --version` shows .NET SDK 10
- [ ] `devenv --version` works
- [ ] `aider --version` works

### User Packages (from home.nix)
- [ ] `git --version` works
- [ ] `gh --version` works (GitHub CLI)
- [ ] `bat --version` works
- [ ] `eza --version` works
- [ ] `fd --version` works
- [ ] `rg --version` works (ripgrep)
- [ ] `fzf --version` works
- [ ] `zoxide --version` works
- [ ] `htop --version` works
- [ ] `btop --version` works

### Homebrew Packages
- [ ] `brew list` shows only: mas, GUI apps (NO CLI duplicates)
- [ ] `mas list` shows Mac App Store apps
- [ ] GUI applications launch correctly:
  - [ ] Hammerspoon (if installed)
  - [ ] IINA (if installed)
  - [ ] VS Code (if via Homebrew)

## Development Environment

### devenv Shell
- [ ] `devenv shell` enters development shell
- [ ] Python available: `python --version` shows Python 3.13+
- [ ] Node.js available: `node --version` works
- [ ] pip available: `pip --version` works
- [ ] Virtual environment activation works
- [ ] Git hooks configured (if using)
- [ ] Exit devenv shell: `exit`

## Application Integration

### Spotlight & Launchpad
- [ ] Open Spotlight (Cmd+Space)
- [ ] Search for installed Nix applications
- [ ] Applications appear and launch correctly
- [ ] `/Applications/Nix Apps/` directory exists
- [ ] Symlinks in `/Applications/Nix Apps/` are valid

### GUI Applications
Test key applications:
- [ ] Visual Studio Code opens
- [ ] Docker Desktop works (if installed)
- [ ] Browser applications work
- [ ] Media applications work (IINA, etc.)

## System Stability

### Performance
- [ ] System responsive
- [ ] No unusual lag
- [ ] Applications launch at normal speed

### Resource Usage
- [ ] `htop` shows normal CPU usage
- [ ] Memory usage reasonable
- [ ] No runaway processes

### Error Checking
- [ ] No error dialogs
- [ ] No system crash reports
- [ ] Console.app shows no critical errors

## Rollback Capability

### Generations Available
- [ ] `darwin-rebuild --list-generations` shows multiple generations
- [ ] `home-manager generations` shows multiple generations
- [ ] Can identify current generation
- [ ] Previous generation available for rollback

### Test Rollback (Optional)
```bash
# Test rollback works
sudo darwin-rebuild --rollback
# If successful, switch back forward
sudo darwin-rebuild switch --flake ~/nix#m4max
```

## Git State

### Repository Clean
- [ ] Changes committed with descriptive message
- [ ] `git status` clean or shows only expected uncommitted files
- [ ] `git log` shows new commit
- [ ] Tag created for stable state (if major change)

### Commit Quality
- [ ] Commit message follows conventional commits format
- [ ] Commit message describes what and why
- [ ] No sensitive information in commit
- [ ] No large binary files committed

## Documentation

### Updated if Needed
- [ ] README.md updated if workflow changed
- [ ] ARCHITECTURE.md updated if structure changed
- [ ] CONTRIBUTING.md updated if process changed
- [ ] New patterns documented

## Notes

Record any issues or observations:

```
Date: _______________
Changes made:



Issues encountered:



Resolutions:



Performance observations:


```

## Quick Test Script

For routine testing, run this:

```bash
# Build test
darwin-rebuild build --flake ~/nix#m4max && echo "✅ Build passed" || echo "❌ Build failed"

# Key packages
which nvim git dotnet && echo "✅ Key packages found" || echo "❌ Packages missing"

# Environment variables
[[ $EDITOR == "nvim" ]] && echo "✅ EDITOR set" || echo "❌ EDITOR wrong"

# Homebrew status
brew list | wc -l && echo "Homebrew packages (should be small number for GUI apps)"
```

## Post-Update Validation

After `nix flake update`:

- [ ] All above tests pass
- [ ] No regressions in functionality
- [ ] Performance remains good
- [ ] No new warnings or errors
- [ ] Applications still work
- [ ] Development environment intact
