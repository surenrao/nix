# Homebrew Configuration
# Manages GUI applications and packages not available in nixpkgs
{ ... }: {
  
  homebrew = {
    enable = true;
    
    # Command-line tools via Homebrew
    brews = [
      "mas"              # Mac App Store command-line interface
      # All CLI/dev tools now managed via Nix for better reproducibility
      # Fonts (Nerd Fonts for terminal icons)
      # "font-fira-code"
      # "font-hack-nerd-font"
    ];
    
    # GUI Applications via Homebrew Casks
    # Apps with their own updater live here rather than in Nix: rebuilds install
    # them on a fresh machine, and the apps keep themselves up to date afterwards.
    casks = [
      # Development Tools
      "visual-studio-code" # Code editor (self-updating)

      # System Automation
      "hammerspoon"      # Desktop automation scripting using Lua

      # Media and Utilities
      "iina"             # Modern media player for macOS
      "the-unarchiver"   # Archive extraction utility
      "pearcleaner"      # Application uninstaller and cleaner

      # Productivity Tools
      "maccy"            # Clipboard manager
      "itsycal"          # Menu bar calendar

      # Creative Tools
      "inkscape"         # Vector graphics editor
    ];
    
    # Mac App Store Applications
    # masApps = {
    #   "Windows App" = 1295203466;    # Microsoft Remote Desktop
    #   "Xcode" = 497799835;           # Apple's development environment
    #   # "Tailscale" = 1475387142;    # VPN service (commented out)
    # };
    #
    # NOTE: These masApps (Microsoft Remote Desktop, Xcode) consistently fail to install
    #       via `darwin-rebuild` due to issues with `mas` in a non-GUI context,
    #       even when logged into the App Store. Manual installation is required,
    #       or these entries should remain commented out.

    
    # Homebrew Maintenance Settings
    # Rebuilds only install what's missing; apps update themselves and
    # anything without an updater can be upgraded manually with `brew upgrade`.
    onActivation = {
      cleanup = "zap";        # Remove unlisted packages
      autoUpdate = false;     # Don't refresh Homebrew on every rebuild
      upgrade = false;        # Don't upgrade packages on rebuild
    };
  };
}

# environment.extraInit = ''
#     export LM_STUDIO_API_KEY=dummy-api-key
#     export LM_STUDIO_API_BASE=http://localhost:1234/v1
#   '';