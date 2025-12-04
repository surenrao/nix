# System Packages Configuration
# Defines all packages installed via Nix package manager
{ pkgs, ... }: {
  
  # Core system packages installed in system profile
  # To search for packages: nix search nixpkgs <package-name>
  environment.systemPackages = with pkgs; [
    # Terminal and Development Tools
    # alacritty          # GPU-accelerated terminal emulator
    neovim            # Modern Vim-based text editor
    tmux              # Terminal multiplexer
      
    # Development Environment
    vscode            # Visual Studio Code editor
    dotnet-sdk_10     # .NET SDK 10 (latest - Nov 2024)

    playwright        # Web testing automation
    # Programming Languages and Runtimes
    direnv            # unclutter your .profile
    devenv            # Declaratively define your development environment

    # AI Development Tools
    aider-chat        # AI pair programming tool
    # ollama            # Local AI model runner
    # open-webui        # UI for ollama

    # Container and Virtualization
    docker            # Container platform
    docker-compose    # Multi-container Docker applications
    colima            # Container runtime for macOS
      
    # System Utilities
    mkalias           # Required for proper app linking to /Applications
  ];
}
