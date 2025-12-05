# User Configuration
# Manages system-level user settings (nix-darwin)
# Note: User-level configurations are handled by Home Manager in home.nix
{ config, pkgs, ... }: {
  
  # System User Configuration
  system.primaryUser = "surenrao";          # Primary system user
  
  # Set fish as default shell for the user
  
  # Note: Shell and Git configurations are handled by Home Manager in home.nix
  # This keeps system-level and user-level configurations properly separated
}