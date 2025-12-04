# Update Strategy

This document describes how to keep this Nix configuration up-to-date.

## Overview

This configuration uses **commit-pinned inputs** for reproducibility. Dependencies are locked to specific commits in `flake.lock`.

**Benefits**:
- Reproducible builds
- Known-good state
- Explicit version control

**Drawback**:
- Requires manual updates

## Update Process

### Regular Updates (Monthly Recommended)

```bash
# 1. Update all inputs to latest
cd ~/nix
nix flake update

# 2. Review changes
git diff flake.lock

# 3. Test build
darwin-rebuild build --flake ~/nix#m4max

# 4. Apply if successful
./rebuild-system.sh

# 5. Test system functionality
# - Open applications
# - Run development tools
# - Check shell utilities

# 6. Commit if stable
git add flake.lock
git commit -m "update: flake inputs $(date +%Y-%m-%d)"

# 7. Tag stable state
git tag stable-$(date +%Y%m%d)
```

### Selective Updates

Update only specific inputs:

```bash
# Update just nixpkgs
nix flake update nixpkgs

# Update just nix-darwin
nix flake update nix-darwin

# Update just Home Manager dependencies
nix flake update
```

### Current Versions

Check what's currently installed:

```bash
# View flake.lock
cat flake.lock | jq '.nodes.nixpkgs.locked'

# Check system generation
darwin-rebuild --list-generations

# Check Home Manager generation
home-manager generations
```

## Rollback Strategy

### If Update Breaks System

**Option 1: Git Rollback**
```bash
git checkout HEAD~1 flake.lock
./rebuild-system.sh
```

**Option 2: Nix Generations**
```bash
sudo darwin-rebuild --rollback
home-manager switch --rollback
```

**Option 3: Specific Generation**
```bash
darwin-rebuild --list-generations
sudo darwin-rebuild switch --switch-generation <number>
```

## Garbage Collection

Clean up old generations to free disk space:

```bash
# Delete generations older than 30 days
sudo nix-collect-garbage --delete-older-than 30d

# Delete all old generations (keep current)
sudo nix-collect-garbage -d

# Optimize nix store
nix-store --optimize
```

## Update Checklist

**Before updating**:
- [ ] Backup: `git tag pre-update-$(date +%Y%m%d)`
- [ ] Review changelog for breaking changes
- [ ] Ensure time for testing
- [ ] Have rollback plan ready

**After updating**:
- [ ] Test system rebuild succeeds
- [ ] Test user environment works
- [ ] Check application functionality
- [ ] Verify development environments
- [ ] Commit stable state
- [ ] Tag if major update

## Update Schedule

**Monthly**: Full update (`nix flake update`)
**Quarterly**: Review and clean old generations
**As-needed**: Security updates for critical packages
**Annually**: Review architecture, major version bumps

## Troubleshooting

### Build Fails After Update

```bash
# 1. Check error with trace
darwin-rebuild switch --flake ~/nix#m4max --show-trace

# 2. Search for breaking changes
# GitHub: NixOS/nixpkgs issues

# 3. Rollback temporarily
git checkout HEAD~1 flake.lock
./rebuild-system.sh

# 4. Fix and retry
```

### Package Version Conflicts

```bash
# Check package version
nix search nixpkgs <package>

# Pin specific version if needed
# Add to packages.nix with specific version
```

## Monitoring Updates

### Check for Available Updates

```bash
# Dry-run to see what would change
nix flake update --dry-run

# View current vs available versions
nix flake metadata
```

### Watch for Breaking Changes

Subscribe to release notes:
- [NixOS/nixpkgs releases](https://github.com/NixOS/nixpkgs/releases)
- [nix-darwin changelog](https://github.com/LnL7/nix-darwin/blob/master/CHANGELOG.md)
- [Home Manager releases](https://github.com/nix-community/home-manager/releases)
