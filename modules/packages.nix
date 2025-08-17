# System Packages Configuration
# Defines all packages installed via Nix package manager
{ pkgs, ... }: {
  
  # Core system packages installed in system profile
  # To search for packages: nix search nixpkgs <package-name>
  environment.systemPackages = with pkgs; [
    # Terminal and Development Tools
    alacritty          # GPU-accelerated terminal emulator
    neovim            # Modern Vim-based text editor
    tmux              # Terminal multiplexer
      
    # Development Environment
    vscode            # Visual Studio Code editor
      
    # Programming Languages and Runtimes
    python3Full       # Python 3 interpreter with pip and development tools
    python3Packages.pip        # Python package installer
    python3Packages.virtualenv # Virtual environment creator
    nodejs            # Node.js JavaScript runtime

    # AI Development Tools
    aider-chat        # AI pair programming tool
    ollama            # Local AI model runner
      
    # Container and Virtualization
    docker            # Container platform
    docker-compose    # Multi-container Docker applications
    colima            # Container runtime for macOS
      
    # System Utilities
    mkalias           # Required for proper app linking to /Applications
  ];
}
