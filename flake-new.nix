{
  description = "Surya MacbookPro2024 nix-darwin system flake";

  inputs = {
    # Nixpkgs: The main Nix package collection
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # https://github.com/nix-darwin/nix-darwin/archive/nix-darwin-25.05.tar.gz
    # nix-darwin: Declarative macOS configuration
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      # Ensure nix-darwin uses the same nixpkgs version as the rest of the flake
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager: User environment management
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # Ensure home-manager uses the same nixpkgs version
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # nix-homebrew only installs Homebrew itself and does not manage any package installed by it
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure it uses your pinned nixpkgs
    };
    
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, ... }:
    let
      # Define your macOS system architecture (aarch64-darwin for Apple Silicon, x86_64-darwin for Intel)
      system = "aarch64-darwin"; 

      # Your macOS hostname (replace with your actual hostname)
      hostname = "m4max";

      # Your macOS username (replace with your actual username)
      username = "surenrao"; 

      # used in git for now
      userEmail = "surenrao@gmail.com";
      
      # home.stateVersion 
      stateVersion: "25.05";

      # Import your nix-darwin system configuration (e.g., in a file named darwin-configuration.nix)
      darwinConfiguration = import ./darwin-configuration.nix {
        inherit pkgs system hostname username inputs;
        # You can pass additional arguments here to your darwin-configuration.nix if needed
      };

      # Import your Home Manager user configuration (e.g., in a file named home-configuration.nix)
      homeConfiguration = import ./home-configuration.nix {
        inherit pkgs system username userEmail inputs release-version;
        # You can pass additional arguments here to your home-configuration.nix if needed
      };

    in {
      # Define the nix-darwin system configuration for your specific machine
      darwinConfigurations.${hostname} = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { 
          inherit inputs; 
          inherit (self) outputs;
          inherit hostname username;
        };
        modules = [
          darwinConfiguration

          # Integrate Home Manager as a nix-darwin module
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = homeConfiguration;
          }
        ];
      };

      # Optionally, you can also define development shells here if you need them
      devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
        packages = with nixpkgs.legacyPackages.${system}; [
          nixpkgs-fmt
          nil # Nix Language Server
        ];
      };
    };
}
