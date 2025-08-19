# Home Manager Configuration
# User-specific packages and configurations managed by Home Manager
{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "surenrao";
  home.homeDirectory = "/Users/surenrao";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  
    # User-specific packages managed by Home Manager
    # These complement the system packages in your nix-darwin configuration
    home.packages = with pkgs; [
      # Development Tools
      git                    # Version control
      gh                     # GitHub CLI
      jq                     # JSON processor
      yq                     # YAML processor
      curl                   # HTTP client
      wget                   # File downloader
      
      # Python Development Tools (basic ones available in nixpkgs)
      python3Packages.pip    # Python package installer
      python3Packages.virtualenv  # Virtual environment creator
      # Note: pipenv, poetry, black, flake8, pytest can be installed via pip in virtual environments
      
      # Shell and Terminal Utilities
      bat                    # Better cat with syntax highlighting
      eza                    # Better ls with colors and icons
      fd                     # Better find
      ripgrep                # Better grep
      fzf                    # Fuzzy finder
      zoxide                 # Smart cd command
      
      # System Monitoring
      htop                   # Process viewer
      btop                   # Resource monitor
      
      # Text Processing
      tree                   # Directory tree viewer
      
      # Fonts (Nerd Fonts for terminal icons)
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  
    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    home.file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;
  
      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };
  
    # Home Manager can also manage your environment variables through
    # 'home.sessionVariables'. These will be explicitly sourced when using a
    # shell provided by Home Manager. If you don't want to manage your shell
    # through Home Manager then you have to manually source 'hm-session-vars.sh'
    # located at either
    #
    #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
    #
    # or
    #
    #  /etc/profiles/per-user/surenrao/etc/profile.d/hm-session-vars.sh
    #
    home.sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "open";
      # Python environment variables
      PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH";
      PIP_USER = "1";  # Install packages to user directory by default
      # OLLAMA configuration variables
      OLLAMA_FLASH_ATTENTION = "1"; # Faster Memory efficient attention
      OLLAMA_KV_CACHE_TYPE = "q8_0"; # Compress context memory
      OLLAMA_CONTEXT_LENGTH = "8192"; # Context window size, can go 32K if llm supports
      OLLAMA_MAX_LOADED_MODELS = "2"; # limit models in memory
    };
  # Program configurations
  programs = {
    # Let Home Manager install and manage itself
    home-manager.enable = true;
    
    # Git configuration
    git = {
      enable = true;
      userName = "Surya Nyayapati";
      userEmail = "surenrao@gmail.com";
      extraConfig = {
        init.defaultBranch = "main";
        push.default = "simple";
        pull.rebase = false;
      };
    };
    
    bash = {
      enable = true;
      # You can add further Bash configuration options here, for example:
      # shellAliases = {
      #   ll = "ls -l";
      #   gc = "git commit";
      # };
      # bashrcExtra = ''
      #   export MY_VAR="hello"
      # '';
    };

    # Fish shell configuration (complements your nix-darwin fish setup)
    fish = {
      enable = true;
      interactiveShellInit = ''
        # Set up zoxide
        zoxide init fish | source
        
        # Export OLLAMA environment variables for compatibility
        set -gx OLLAMA_FLASH_ATTENTION "1"
        set -gx OLLAMA_KV_CACHE_TYPE "q8_0"
        set -gx OLLAMA_CONTEXT_LENGTH "8192"
        set -gx OLLAMA_MAX_LOADED_MODELS "2"
        
        # Aliases
        alias ls="eza --icons"
        alias ll="eza -l --icons"
        alias la="eza -la --icons"
        alias cat="bat"
        alias cd="z"
      '';
    };

    # Set fish as default shell for user
    # This is handled through nix-darwin configuration, but we ensure fish is available
    # The actual shell setting is done in system configuration

    # Starship prompt
    starship = {
      enable = true;
      settings = {
        format = "$all$character";
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };
    
    # Zoxide (smart cd)
    zoxide.enable = true;
    
    # Fzf (fuzzy finder)
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    
    # Bat (better cat)
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };
  };
}