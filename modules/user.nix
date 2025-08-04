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