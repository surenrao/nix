# Python Development Environment Configuration
# Configures devenv for Python development
{ pkgs, config, ... }: {

  # Note: Actual devenv configuration is defined in devenv.nix
  # This module just ensures the necessary packages are available
  
  # System packages needed for Python development
  environment.systemPackages = with pkgs; [
    # devenv is already included in packages.nix
    # Additional Python tools that might be useful
    python3Packages.pip
    python3Packages.virtualenv
  ];
}
