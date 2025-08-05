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

  # Flake Inputs - All URLs pinned to specific commits for reproducibility
  inputs = {
    # Nixpkgs - Using unstable branch (recommended for nix-darwin)
    nixpkgs.url = "github:NixOS/nixpkgs/bf9fa86a9b1005d932f842edf2c38eeecc98eef3";
    
    # Nix-Darwin - Declarative macOS configuration management
    nix-darwin.url = "github:LnL7/nix-darwin/e04a388232d9a6ba56967ce5b53a8a6f713cdfcf";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    # Home Manager - User environment management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # Nix-Homebrew - Homebrew integration for Nix
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew/314d057294e79bc2596972126b84c6f9f144499a";
    
    # Mac-App-Util - macOS application utilities for better app integration
    mac-app-util.url = "github:hraban/mac-app-util/341ede93f290df7957047682482c298e47291b4d";
  };

  # Flake Outputs
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, mac-app-util }: {
    
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
  };
}
