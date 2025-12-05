{
  # Nix Darwin System Configuration for MacBook Pro M4 Max
  # 
  # References:
  # - https://www.youtube.com/watch?v=Z8BL8mdzWHI
  # - https://github.com/dreamsofautonomy/nix-darwin/blob/main/flake.nix
  #
  # Usage:
  #   darwin-rebuild switch --flake ~/nix#m4max
  
  description = "Surya MacbookPro2024 nix-darwin system flake - modular configuration";

  # Flake Inputs - Following latest stable branches (will be pinned after testing)
  inputs = {
    # Nixpkgs - Using unstable branch (recommended for nix-darwin)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Nix-Darwin - Declarative macOS configuration management
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Nix-Homebrew - Homebrew integration for Nix
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Mac-App-Util - macOS application utilities for better app integration
    mac-app-util.url = "github:hraban/mac-app-util";

    # Devenv - Development environment for Nix
    devenv.url = "github:cachix/devenv";
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Flake Outputs
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, mac-app-util, devenv, flake-utils }: {
    
    # Darwin System Configuration
    darwinConfigurations."m4max" = nix-darwin.lib.darwinSystem {
      modules = [
        # Import all configuration modules
        ./modules/packages.nix
        ./modules/homebrew.nix
        ./modules/system-defaults.nix
        ./modules/applications.nix
        ./modules/security.nix
        ./modules/nix-config.nix
        ./modules/user.nix
        
        # External modules
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        
        # Note: Home Manager is configured as standalone
        # Run 'home-manager switch' after 'darwin-rebuild switch' for full setup
        
        # Nix-Homebrew configuration
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;           # Apple Silicon Rosetta 2 support
            user = "surenrao";              # Homebrew prefix owner
            # autoMigrate = true;           # Uncomment to migrate existing Homebrew
          };
        }
        
        # Set configuration revision for tracking
        {
          system.configurationRevision = self.rev or self.dirtyRev or null;
        }
      ];
    };

    # Expose package set for convenience
    darwinPackages = self.darwinConfigurations."m4max".pkgs;
    
    # Development shells
    devShells.aarch64-darwin.default = devenv.lib.mkShell {
      inherit inputs;
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      modules = [
        ./devenv.nix
      ];
    };
  };
}
