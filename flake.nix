{
  # https://www.youtube.com/watch?v=Z8BL8mdzWHI
  # https://github.com/dreamsofautonomy/nix-darwin/blob/main/flake.nix
  # darwin-rebuild switch --flake ~/nix#m4max
  description = "Surya MacbookPro2024 nix-darwin system flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/8809585e6937d0b07fc066792c8c9abf9c3fe5c4";
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
          "pearcleaner"
          # clipboard manager
          "maccy"
          "itsycal"
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
      # fonts.packages = [
      #   (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      # ];

      # Installing Rosetta 2 https://github.com/LnL7/nix-darwin/issues/786
      # system.activationScripts.extraActivation.text = ''
      #  softwareupdate --install-rosetta --agree-to-license
      # '';

      # system.activationScripts.postUserActivation.text = ''
      #   # Following line should allow us to avoid a logout/login cycle
      #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      # '';

      # https://nixcademy.com/posts/nix-on-macos/
      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

      # MacOS system setting https://mynixos.com/nix-darwin/options/system.defaults
      system.defaults = {
        dock.autohide  = true;
        dock.persistent-apps = [         
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
          # When performing a search, search the current folder by default
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

        CustomUserPreferences = {
          NSGlobalDomain = {
            # Add a context menu item for showing the Web Inspector in web views
            WebKitDeveloperExtras = true;
          };
          "com.apple.finder" = {
            ShowExternalHardDrivesOnDesktop = true;
            ShowHardDrivesOnDesktop = true;
            ShowMountedServersOnDesktop = true;
            ShowRemovableMediaOnDesktop = true;
          };
          "com.apple.desktopservices" = {
            # Avoid creating .DS_Store files on network or USB volumes
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.screensaver" = {
            # Require password immediately after sleep or screen saver begins
            # askForPassword = 1;
            # askForPasswordDelay = 0;
          };
          "com.apple.screencapture" = {
            location = "~/Desktop";
            type = "png";
          };
          # "com.apple.Safari" = {
          #   # Privacy: don’t send search queries to Apple
          #   UniversalSearchEnabled = false;
          #   SuppressSearchSuggestions = true;
          #   # Press Tab to highlight each item on a web page
          #   WebKitTabToLinksPreferenceKey = true;
          #   ShowFullURLInSmartSearchField = true;
          #   # Prevent Safari from opening ‘safe’ files automatically after downloading
          #   AutoOpenSafeDownloads = false;
          #   ShowFavoritesBar = false;
          #   IncludeInternalDebugMenu = true;
          #   IncludeDevelopMenu = true;
          #   WebKitDeveloperExtrasEnabledPreferenceKey = true;
          #   WebContinuousSpellCheckingEnabled = true;
          #   WebAutomaticSpellingCorrectionEnabled = false;
          #   AutoFillFromAddressBook = false;
          #   AutoFillCreditCardData = false;
          #   AutoFillMiscellaneousForms = false;
          #   WarnAboutFraudulentWebsites = true;
          #   WebKitJavaEnabled = false;
          #   WebKitJavaScriptCanOpenWindowsAutomatically = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks" = true;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled" = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WsebKit2JavaEnabled" = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabledForLocalFiles" = false;
          #   "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" = false;
          # };
          # "com.apple.mail" = {
          #   # Disable inline attachments (just show the icons)
          #   DisableInlineAttachmentViewing = true;
          # };
          "com.apple.AdLib" = {
            allowApplePersonalizedAdvertising = false;
          };
          "com.apple.print.PrintingPrefs" = {
            # Automatically quit printer app once the print jobs complete
            "Quit When Finished" = true;
          };

          # "com.apple.LSShadowIndex" = true;
          "com.apple.SoftwareUpdate" = {
            AutomaticCheckEnabled = true;
            # Check for software updates daily, not just once per week
            ScheduleFrequency = 1;
            # Download newly available updates in background
            AutomaticDownload = 1;
            # Install System data files & security updates
            CriticalUpdateInstall = 1;
          };
          "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
          # Prevent Photos from opening automatically when devices are plugged in
          "com.apple.ImageCapture".disableHotPlug = true;
          # Turn on app auto-update
          "com.apple.commerce".AutoUpdate = true;
        };
      };


      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

     # programs.git = {
     #   enable = true;
     #   userName  = "Surya Nyayapati";
     #   userEmail = "surenrao@gmail.com";
     # };

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
