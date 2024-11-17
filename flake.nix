{
  # https://www.youtube.com/watch?v=Z8BL8mdzWHI
  # https://github.com/dreamsofautonomy/nix-darwin/blob/main/flake.nix
  description = "Surya MacbookPro2024 nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";  
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, mac-app-util }:
  let
    configuration = { pkgs, config, ... }: {
      
      # Allow non open source code to be installed.
      nixpkgs.config.allowUnfree = true;

      # Use touch Id for sudo
      security.pam.enableSudoTouchIdAuth = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.alacritty
          # pkgs.mkalias 
          pkgs.neovim
          pkgs.vscode
          pkgs.tmux
          pkgs.docker
          pkgs.docker-compose
          pkgs.colima
        ];
      
      # Homebrew, anything not found above can be done by homwbrew 
      homebrew = {
        enable = true;
        brews = [
          # Mac App Store cli
          "mas"
        ];
        # GUI apps
        casks = [
          # desktop automation scripting using lua
          "hammerspoon"
          # "firefox"
          # video player
          "iina"
          # unzip etc
          "the-unarchiver"
        ];
        # mac store apps
        masApps = {
          "Windows App" = 1295203466;
          "Xcode" = 497799835;
          # "Tailscale" = 1475387142;
        };
        # this will remove any homebrew apps not listed here
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };
      
      # Font package for Alacrity.
      fonts.packages = [
        (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];

      # Installing Rosetta 2 https://github.com/LnL7/nix-darwin/issues/786
      # system.activationScripts.extraActivation.text = ''
      #  softwareupdate --install-rosetta --agree-to-license
      # '';
      
      # https://nixcademy.com/posts/nix-on-macos/
      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

      # MacOS system setting https://mynixos.com/nix-darwin/options/system.defaults
      system.defaults = {
        dock.autohide  = true;
        dock.persistent-apps = [
	      # "/System/Library/CoreServices/Finder.app"          
	        "/System/Applications/Launchpad.app"	  
	        "/Applications/Firefox.app"
          "/Applications/Google Chrome.app"
 	        "/System/Applications/Messages.app"
          "/System/Applications/Calendar.app"
	        "/System/Applications/Mail.app"
          "/System/Applications/App Store.app"   
          "/System/Applications/Notes.app"
          "/System/Applications/iPhone Mirroring.app"
          "/System/Applications/System Settings.app"
	        "${pkgs.alacritty}/Applications/Alacritty.app"
          "/System/Applications/Utilities/Terminal.app"        
          "/Applications/Skype.app"
	      ];        
        
        finder = {
	        FXPreferredViewStyle = "clmv";
          _FXSortFoldersFirst = true;
          AppleShowAllExtensions = true;
          FXDefaultSearchScope = "SCcf";
          ShowPathbar = true;
	        ShowStatusBar = true;
	      };

	      controlcenter = {
           BatteryShowPercentage = true;
        };

        loginwindow.GuestEnabled  = false;
        
        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleShowAllExtensions = true;
        };
      };


      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."m4max" = nix-darwin.lib.darwinSystem {
      modules = [
          configuration
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              # Apple Silicon Only
              enableRosetta = true;
              # User owning the Homebrew prefix
              user = "surenrao";
              # Automatically migrate existing Homebrew installations
              # autoMigrate = true;
            };
          }
       ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."m4max".pkgs;
  };
}
