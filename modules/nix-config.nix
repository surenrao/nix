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
    # Used for backwards compatibility, please read the changelog before changing
    # Reference: $ darwin-rebuild changelog
    # Updated to 5 for compatibility with NixOS 24.11
    stateVersion = 5;
    
    # Target platform architecture
    nixpkgs.hostPlatform = "aarch64-darwin";  # Apple Silicon
  };
}