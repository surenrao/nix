# darwin-configuration.nix
{ pkgs, ... }: {
  # Example: Install some system-wide packages
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
  ];

  # Enable Nix Daemon service for flake functionality
  services.nix-daemon.enable = true;

  # Enable experimental features for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Configure your shell (e.g., Zsh)
  programs.zsh.enable = true;

  # Define your user and home directory (used by nix-darwin)
  users.users.${username} = {
    name = "${username}"; # Replace with your actual username
    home = "/Users/${username}"; # Replace with your actual home directory
  };
}
