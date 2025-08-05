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

# environment.extraInit = ''
#     export LM_STUDIO_API_KEY=dummy-api-key
#     export LM_STUDIO_API_BASE=http://localhost:1234/v1
#   '';