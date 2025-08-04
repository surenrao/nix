# Nix Darwin Flake Refactoring Plan

## Overview
This document outlines the complete refactoring plan for making the `flake.nix` file modular with proper comments and organization.

## Current Structure Analysis

The current `flake.nix` file contains approximately 307 lines with the following components mixed together:
- System packages configuration
- Homebrew configuration (brews, casks, Mac App Store apps)
- macOS system defaults (dock, finder, control center, etc.)
- Application linking script for Spotlight integration
- Security and authentication settings
- Nix daemon configuration
- User configuration

## Proposed Modular Structure

### Directory Layout
```
.
├── flake.nix                 # Main flake file (simplified)
├── flake.lock               # Lock file (unchanged)
└── modules/
    ├── packages.nix         # System packages configuration
    ├── homebrew.nix         # Homebrew configuration
    ├── system-defaults.nix  # macOS system defaults
    ├── applications.nix     # Application linking and Spotlight integration
    ├── security.nix         # Security and authentication settings
    ├── nix-config.nix       # Nix daemon and experimental features
    └── user.nix             # User and shell configuration
```

## Module Specifications

### 1. `modules/packages.nix`
**Purpose**: Define all Nix packages to be installed system-wide
**Content**:
```nix
# System Packages Configuration
# Defines all packages installed via Nix package manager
{ pkgs, ... }: {
  
  # Core system packages installed in system profile
  # To search for packages: nix search nixpkgs <package-name>
  environment.systemPackages = with pkgs; [
    # Terminal and Development Tools
    alacritty          # GPU-accelerated terminal emulator
    neovim            # Modern Vim-based text editor
    tmux              # Terminal multiplexer
    
    # Development Environment
    vscode            # Visual Studio Code editor
    
    # Container and Virtualization
    docker            # Container platform
    docker-compose    # Multi-container Docker applications
    colima            # Container runtime for macOS
    
    # System Utilities
    mkalias           # Required for proper app linking to /Applications
  ];
}
```

### 2. `modules/homebrew.nix`
**Purpose**: Configure Homebrew packages, casks, and Mac App Store apps
**Content**:
```nix
# Homebrew Configuration
# Manages GUI applications and packages not available in nixpkgs
{ ... }: {
  
  homebrew = {
    enable = true;
    
    # Command-line tools via Homebrew
    brews = [
      "mas"              # Mac App Store command-line interface
    ];
    
    # GUI Applications via Homebrew Casks
    casks = [
      # System Automation
      "hammerspoon"      # Desktop automation scripting using Lua
      
      # Media and Utilities
      "iina"             # Modern media player for macOS
      "the-unarchiver"   # Archive extraction utility
      "pearcleaner"      # Application uninstaller and cleaner
      
      # Productivity Tools
      "maccy"            # Clipboard manager
      "itsycal"          # Menu bar calendar
      
      # AI and Development
      "lm-studio"        # Local LLM inference engine
    ];
    
    # Mac App Store Applications
    masApps = {
      "Windows App" = 1295203466;    # Microsoft Remote Desktop
      "Xcode" = 497799835;           # Apple's development environment
      # "Tailscale" = 1475387142;    # VPN service (commented out)
    };
    
    # Homebrew Maintenance Settings
    onActivation = {
      cleanup = "zap";        # Remove unlisted packages
      autoUpdate = true;      # Auto-update Homebrew
      upgrade = true;         # Auto-upgrade packages
    };
  };
}
```

### 3. `modules/system-defaults.nix`
**Purpose**: Configure macOS system defaults and preferences
**Content**:
```nix
# macOS System Defaults Configuration
# Configures system-wide macOS preferences and behaviors
# Reference: https://mynixos.com/nix-darwin/options/system.defaults
{ pkgs, ... }: {
  
  system.defaults = {
    
    # Dock Configuration
    dock = {
      autohide = true;           # Auto-hide dock when not in use
      
      # Persistent applications in dock (in order)
      persistent-apps = [
        "/System/Applications/Launchpad.app"
        "/Applications/Firefox.app"
        "/Applications/Google Chrome.app"
        "/System/Applications/Messages.app"
        "/System/Applications/Calendar.app"
        "/System/Applications/Mail.app"
        "/System/Applications/App Store.app"
        "/System/Applications/Notes.app"
        "/System/Applications/iPhone Mirroring.app"
        "/System/Applications/System Settings.app"
        "${pkgs.alacritty}/Applications/Alacritty.app"
        "/System/Applications/Utilities/Terminal.app"
      ];
    };
    
    # Finder Configuration
    finder = {
      FXPreferredViewStyle = "clmv";        # Column view by default
      _FXSortFoldersFirst = true;           # Show folders first
      AppleShowAllExtensions = true;        # Show all file extensions
      FXDefaultSearchScope = "SCcf";        # Search current folder by default
      ShowPathbar = true;                   # Show path bar
      ShowStatusBar = true;                 # Show status bar
    };
    
    # Control Center Configuration
    controlcenter = {
      BatteryShowPercentage = true;         # Show battery percentage
    };
    
    # Login Window Configuration
    loginwindow = {
      GuestEnabled = false;                 # Disable guest user
    };
    
    # Global Domain Settings
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";         # Use dark mode
      AppleShowAllExtensions = true;        # Show file extensions globally
    };
    
    # Custom Application Preferences
    CustomUserPreferences = {
      
      # Global WebKit Settings
      NSGlobalDomain = {
        WebKitDeveloperExtras = true;       # Enable web inspector in web views
      };
      
      # Finder Extended Settings
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
      };
      
      # Desktop Services Configuration
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;    # No .DS_Store on network volumes
        DSDontWriteUSBStores = true;        # No .DS_Store on USB volumes
      };
      
      # Screen Capture Settings
      "com.apple.screencapture" = {
        location = "~/Desktop";             # Save screenshots to Desktop
        type = "png";                       # Use PNG format
      };
      
      # Privacy and Advertising
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      
      # Printing Preferences
      "com.apple.print.PrintingPrefs" = {
        "Quit When Finished" = true;       # Auto-quit printer app
      };
      
      # Software Update Settings
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;       # Check for updates automatically
        ScheduleFrequency = 1;              # Check daily
        AutomaticDownload = 1;              # Download updates automatically
        CriticalUpdateInstall = 1;          # Install security updates
      };
      
      # Time Machine Settings
      "com.apple.TimeMachine" = {
        DoNotOfferNewDisksForBackup = true;
      };
      
      # Image Capture Settings
      "com.apple.ImageCapture" = {
        disableHotPlug = true;              # Don't auto-open Photos
      };
      
      # App Store Settings
      "com.apple.commerce" = {
        AutoUpdate = true;                  # Auto-update apps
      };
    };
  };
}
```

### 4. `modules/applications.nix`
**Purpose**: Handle application linking and Spotlight integration
**Content**:
```nix
# Application Linking and Spotlight Integration
# Ensures Nix-installed applications appear in Spotlight and Launchpad
{ pkgs, config, ... }: {
  
  # Application linking script for Spotlight and Launchpad integration
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications for Spotlight and Launchpad integration
      echo "Setting up /Applications for Spotlight integration..." >&2
      
      # Clean up existing Nix Apps directory
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      
      # Create symbolic links for each application
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "Linking $src -> /Applications/Nix Apps/$app_name" >&2
        # Use symbolic links instead of aliases for better Spotlight integration
        ln -sf "$src" "/Applications/Nix Apps/$app_name"
      done
      
      # Force Spotlight to reindex the Applications folder
      echo "Reindexing Spotlight for Applications..." >&2
      /usr/bin/mdimport -r /Applications/Nix\ Apps/ || true
      
      # Register applications with Launch Services
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -f -R -domain local -domain system -domain user /Applications/Nix\ Apps/ || true
      
      echo "Application linking complete." >&2
    '';
}
```

### 5. `modules/security.nix`
**Purpose**: Configure security and authentication settings
**Content**:
```nix
# Security and Authentication Configuration
# Manages system security settings and authentication methods
{ ... }: {
  
  # Touch ID Configuration
  security.pam.services.sudo_local.touchIdAuth = true;  # Enable Touch ID for sudo
  
  # Login Window Security
  system.defaults.loginwindow.GuestEnabled = false;     # Disable guest user access
  
  # Screen Saver Security (commented out - can be enabled if needed)
  # system.defaults.CustomUserPreferences."com.apple.screensaver" = {
  #   askForPassword = 1;        # Require password after screen saver
  #   askForPasswordDelay = 0;   # Require password immediately
  # };
}
```

### 6. `modules/nix-config.nix`
**Purpose**: Configure Nix daemon and experimental features
**Content**:
```nix
# Nix Configuration
# Manages Nix daemon settings and experimental features
{ ... }: {
  
  # Nixpkgs Configuration
  nixpkgs.config.allowUnfree = true;        # Allow proprietary software
  
  # Nix Daemon Settings
  nix = {
    # Enable experimental features required for flakes
    settings.experimental-features = "nix-command flakes";
    
    # Multi-platform support for cross-compilation
    # Reference: https://nixcademy.com/posts/nix-on-macos/
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };
  
  # System Configuration Metadata
  system = {
    # Set Git commit hash for darwin-version tracking
    configurationRevision = null;  # Will be set by flake
    
    # State version for backwards compatibility
    # Reference: $ darwin-rebuild changelog
    stateVersion = 5;  # Updated for NixOS 24.11 compatibility
    
    # Target platform architecture
    nixpkgs.hostPlatform = "aarch64-darwin";  # Apple Silicon
  };
}
```

### 7. `modules/user.nix`
**Purpose**: Configure user settings and shell environment
**Content**:
```nix
# User Configuration
# Manages user-specific settings and shell environment
{ ... }: {
  
  # System User Configuration
  system.primaryUser = "surenrao";          # Primary system user
  
  # Shell Configuration
  programs.fish.enable = true;              # Enable Fish shell support
  
  # Git Configuration (commented out - can be enabled if needed)
  # programs.git = {
  #   enable = true;
  #   userName = "Surya Nyayapati";
  #   userEmail = "surenrao@gmail.com";
  # };
}
```

## Refactored Main `flake.nix`

The main flake file will be significantly simplified:

```nix
{
  # Nix Darwin System Configuration for MacBook Pro M4 Max
  # 
  # References:
  # - https://www.youtube.com/watch?v=Z8BL8mdzWHI
  # - https://github.com/dreamsofautonomy/nix-darwin/blob/main/flake.nix
  #
  # Usage:
  #   darwin-rebuild switch --flake ~/nix#m4max
  
  description = "Surya MacbookPro2024 nix-darwin system flake - modular configuration";

  # Flake Inputs - All URLs pinned to specific commits for reproducibility
  inputs = {
    # Nixpkgs - Using unstable branch (recommended for nix-darwin)
    nixpkgs.url = "github:NixOS/nixpkgs/bf9fa86a9b1005d932f842edf2c38eeecc98eef3";
    
    # Nix-Darwin - Declarative macOS configuration management
    nix-darwin.url = "github:LnL7/nix-darwin/e04a388232d9a6ba56967ce5b53a8a6f713cdfcf";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # Nix-Homebrew - Homebrew integration for Nix
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew/314d057294e79bc2596972126b84c6f9f144499a";
    
    # Mac-App-Util - macOS application utilities for better app integration
    mac-app-util.url = "github:hraban/mac-app-util/341ede93f290df7957047682482c298e47291b4d";
  };

  # Flake Outputs
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, mac-app-util }: {
    
    # Darwin System Configuration
    darwinConfigurations."m4max" = nix-darwin.lib.darwinSystem {
      modules = [
        # Import all configuration modules
        ./modules/packages.nix
        ./modules/homebrew.nix
        ./modules/system-defaults.nix
        ./modules/applications.nix
        ./modules/security.nix
        ./modules/nix-config.nix
        ./modules/user.nix
        
        # External modules
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        
        # Nix-Homebrew configuration
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;           # Apple Silicon Rosetta 2 support
            user = "surenrao";              # Homebrew prefix owner
            # autoMigrate = true;           # Uncomment to migrate existing Homebrew
          };
        }
        
        # Set configuration revision for tracking
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }
      ];
    };

    # Expose package set for convenience
    darwinPackages = self.darwinConfigurations."m4max".pkgs;
  };
}
```

## Implementation Steps

1. **Create modules directory**: `mkdir modules`
2. **Create each module file** with the content specified above
3. **Replace the main flake.nix** with the refactored version
4. **Test the configuration**: `darwin-rebuild switch --flake ~/nix#m4max`
5. **Verify all functionality** works as expected

## Benefits of This Refactoring

1. **Modularity**: Each configuration area is in its own file
2. **Maintainability**: Easier to modify specific aspects without affecting others
3. **Readability**: Clear separation of concerns with comprehensive comments
4. **Reusability**: Modules can be easily shared or adapted for other systems
5. **Documentation**: Each module is self-documenting with detailed comments
6. **Version Control**: Changes to specific areas are easier to track in git

## Testing Checklist

After implementing the refactoring:

- [ ] System rebuilds successfully
- [ ] All Nix packages are installed
- [ ] Homebrew applications are present
- [ ] macOS system defaults are applied
- [ ] Applications appear in Spotlight
- [ ] Touch ID works for sudo
- [ ] Dock configuration is correct
- [ ] All custom preferences are applied

## Future Enhancements

Consider these additional improvements:
- Add host-specific configurations for multiple machines
- Create user-specific modules for different users
- Add development environment modules (Node.js, Python, etc.)
- Implement conditional configurations based on system properties