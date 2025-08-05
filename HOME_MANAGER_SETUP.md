# Home Manager Standalone Setup

This document describes the home-manager standalone installation and configuration that complements your existing nix-darwin system configuration.

## 📋 Overview

Home Manager is now installed as a standalone solution to manage user-specific packages and configurations, working alongside your existing nix-darwin system configuration. This provides a clean separation between system-level and user-level package management.

## 🏗️ Architecture

- **nix-darwin** (system-level): Manages system packages, macOS defaults, and system services
- **home-manager** (user-level): Manages user packages, dotfiles, and user-specific configurations

## 📦 Installation Summary

### What Was Installed

1. **Home Manager Channel**: Added and updated the home-manager channel
2. **Home Manager Tool**: Installed the `home-manager` command-line tool
3. **Initial Configuration**: Created `/Users/surenrao/.config/home-manager/home.nix`

### User Packages Added

The following packages are now managed by home-manager:

#### Development Tools
- [`git`](https://git-scm.com/) - Version control system
- [`gh`](https://cli.github.com/) - GitHub CLI
- [`jq`](https://jqlang.github.io/jq/) - JSON processor
- [`yq`](https://github.com/mikefarah/yq) - YAML processor
- [`curl`](https://curl.se/) - HTTP client
- [`wget`](https://www.gnu.org/software/wget/) - File downloader

#### Python Development Tools
- [`pip`](https://pip.pypa.io/) - Python package installer (user-level)
- [`virtualenv`](https://virtualenv.pypa.io/) - Virtual environment creator (user-level)

#### Shell and Terminal Utilities
- [`bat`](https://github.com/sharkdp/bat) - Better cat with syntax highlighting
- [`eza`](https://github.com/eza-community/eza) - Better ls with colors and icons
- [`fd`](https://github.com/sharkdp/fd) - Better find
- [`ripgrep`](https://github.com/BurntSushi/ripgrep) - Better grep (available as `rg`)
- [`fzf`](https://github.com/junegunn/fzf) - Fuzzy finder
- [`zoxide`](https://github.com/ajeetdsouza/zoxide) - Smart cd command

#### System Monitoring
- [`htop`](https://htop.dev/) - Process viewer
- [`btop`](https://github.com/aristocratos/btop) - Resource monitor

#### Text Processing
- [`tree`](https://mama.indstate.edu/users/ice/tree/) - Directory tree viewer

#### Fonts
- **Nerd Fonts**: FiraCode and JetBrains Mono with programming ligatures and icons

### Program Configurations

#### Git Configuration
- **User**: Surya Nyayapati
- **Email**: surenrao@gmail.com
- **Default Branch**: main
- **Push Strategy**: simple

#### Fish Shell Enhancements
- **Zoxide integration**: Smart directory navigation
- **Aliases**:
  - `ls` → `eza --icons`
  - `ll` → `eza -l --icons`
  - `la` → `eza -la --icons`
  - `cat` → `bat`
  - `cd` → `z` (zoxide)

#### Starship Prompt
- Modern, fast shell prompt with git integration
- Custom success/error symbols

#### Bat Configuration
- **Theme**: TwoDark
- **Style**: Line numbers, changes, and header

## 🚀 Usage

### Unified Rebuild (Recommended)
Use the unified rebuild script to apply both system and user configurations:
```bash
./rebuild-system.sh
```

### Managing Home Manager Individually

```bash
# Apply configuration changes
home-manager switch

# Check configuration without applying
home-manager build

# List generations
home-manager generations

# Rollback to previous generation
home-manager switch --rollback

# View news and updates
home-manager news
```

### Configuration File

The main configuration file is now located in your workspace modules directory:
```
/Users/surenrao/nix/modules/home.nix
```

This file is symlinked from the default home-manager location (`~/.config/home-manager/home.nix`) for compatibility.

### Adding New Packages

To add new packages, edit the `home.packages` section in [`modules/home.nix`](modules/home.nix):

```nix
home.packages = with pkgs; [
  # Existing packages...
  
  # Add new packages here
  your-new-package
];
```

Then apply the changes:
```bash
home-manager switch
# OR use the unified rebuild script
./rebuild-system.sh
```

## 🔄 Integration with Nix-Darwin

### Complementary Setup

- **System packages** (nix-darwin): Alacritty, Neovim, Tmux, VSCode, Docker, Python 3.13.5
- **User packages** (home-manager): Git, development tools, shell utilities, Python tools
- **System settings** (nix-darwin): macOS defaults, security, Homebrew, environment variables
- **User settings** (home-manager): Dotfiles, shell configuration, user programs

### Python Development Environment

#### System-Level (nix-darwin)
- **Python 3.13.5** with full development tools
- **pip 25.0.1** system-wide installation
- **virtualenv 20.31.2** system-wide installation

#### User-Level (home-manager)
- Additional Python tools and completions
- User-specific Python environment variables
- Shell integrations for Python development

#### LM Studio Integration
System-wide environment variables configured in [`modules/user.nix`](modules/user.nix):
- `LM_STUDIO_API_KEY=lm-studio`
- `LM_STUDIO_API_BASE=http://localhost:1234/v1`

### Avoiding Conflicts

- System-level packages remain in [`modules/packages.nix`](modules/packages.nix)
- User-level packages are managed in home-manager
- No package duplication between the two systems

## 🛠️ Customization

### Shell Configuration

Fish shell is configured in both systems:
- **nix-darwin**: Enables Fish system-wide
- **home-manager**: Configures Fish with aliases and integrations

### Adding Dotfiles

Use the `home.file` section to manage dotfiles:

```nix
home.file = {
  ".vimrc".text = ''
    set number
    set relativenumber
  '';
  
  ".gitignore_global".source = ./dotfiles/gitignore_global;
};
```

### Environment Variables

Set user-specific environment variables:

```nix
home.sessionVariables = {
  EDITOR = "nvim";
  BROWSER = "open";
  CUSTOM_VAR = "value";
};
```

## 📚 Useful Commands

### Package Management
```bash
# Search for packages
nix search nixpkgs package-name

# Check what's installed
home-manager packages
```

### Shell Integration
```bash
# Use new aliases (after home-manager switch)
ls          # Uses eza with icons
ll          # Long listing with eza
cat file    # Uses bat with syntax highlighting
z directory # Smart cd with zoxide
```

### Development Workflow
```bash
# Git is now configured
git config --list

# GitHub CLI is available
gh auth login

# JSON/YAML processing
echo '{"key": "value"}' | jq .
echo 'key: value' | yq .

# Python development
python3 --version
pip --version
virtualenv myproject
source myproject/bin/activate

# AI development with Aider + LM Studio
aider --model lm-studio/your-model-name
```

## 🔧 Troubleshooting

### Common Issues

1. **Command not found after installation**
   ```bash
   # Reload your shell or source the profile
   source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
   ```

2. **Configuration errors**
   ```bash
   # Check configuration syntax
   home-manager build
   
   # Show detailed error trace
   home-manager switch --show-trace
   ```

3. **Rollback if needed**
   ```bash
   home-manager switch --rollback
   ```

### Getting Help

```bash
# View all home-manager options
man home-configuration.nix

# Check home-manager version
home-manager --version

# View recent news and changes
home-manager news
```

## 🎯 Next Steps

1. **Customize the configuration** to match your preferences
2. **Add more packages** as needed for your workflow
3. **Configure additional programs** using home-manager modules
4. **Set up dotfiles** management for your configuration files
5. **Explore home-manager modules** for applications like tmux, neovim, etc.

## 📖 References

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nix Package Search](https://search.nixos.org/packages)
- [Your Nix-Darwin Configuration](README.md)