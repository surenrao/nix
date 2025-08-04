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
    python3           # Python 3 interpreter
    nodejs            # Node.js JavaScript runtime
    python3.pkgs.python-packages  # pip package manager

    # AI Development Tools
    aider-chat        # AI pair programming tool
      
    # Container and Virtualization
    docker            # Container platform
    docker-compose    # Multi-container Docker applications
    colima            # Container runtime for macOS
      
    # System Utilities
    mkalias           # Required for proper app linking to /Applications
  ];
    
  environment.extraInit = ''
    export LM_STUDIO_API_KEY=dummy-api-key
    export LM_STUDIO_API_BASE=http://localhost:1234/v1
  '';
}
