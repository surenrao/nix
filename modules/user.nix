# User Configuration
# Manages system-level user settings (nix-darwin)
# Note: User-level configurations are handled by Home Manager in home.nix
{ ... }: {
  
  # System User Configuration
  system.primaryUser = "surenrao";          # Primary system user
  
  # Note: Shell and Git configurations are handled by Home Manager in home.nix
  # This keeps system-level and user-level configurations properly separated
}