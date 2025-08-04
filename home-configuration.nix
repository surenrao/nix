# home-configuration.nix
{ config, pkgs, ... }: {
  # Example: Install user-specific packages
  home.packages = with pkgs; [
    alacritty # A GPU-accelerated terminal emulator
    neovim # Modern Vim text editor
    tmux # Terminal multiplexer
  ];

  # Enable Home Manager to manage dotfiles in XDG Base Directory Specification locations
  xdg.enable = true;

  # Configure Git with your user details
  programs.git = {
    enable = true;
    userName = "${username}";
    userEmail = "${userEmail}";
  };

  # Configure your Zsh shell
  programs.zsh = {
    enable = true;
    # You can add plugins, aliases, etc. here
  };

  # Set a default Home Manager state version (read the changelog for details)
  home.stateVersion = "${stateVersion}"; # Match this with your home-manager URL branch
}
