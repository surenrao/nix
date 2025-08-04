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