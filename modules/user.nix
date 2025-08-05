# User Configuration
# Manages system-level user settings (nix-darwin)
# Note: User-level configurations are handled by Home Manager in home.nix
{ ... }: {
  
  # System User Configuration
  system.primaryUser = "surenrao";          # Primary system user
  
  # Environment Variables (system-wide)
  environment.variables = {
    # LM Studio API configuration for Aider
    LM_STUDIO_API_KEY = "lm-studio";
    LM_STUDIO_API_BASE = "http://localhost:1234/v1";
  };
  
  # Note: Shell and Git configurations are handled by Home Manager in home.nix
  # This keeps system-level and user-level configurations properly separated
}