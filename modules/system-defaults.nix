# macOS System Defaults Configuration
# Configures system-wide macOS preferences and behaviors
# Reference: https://mynixos.com/nix-darwin/options/system.defaults
{ pkgs, ... }: {
  
  system.defaults = {
    
    # Dock Configuration
    dock = {
      autohide = true;           # Auto-hide dock when not in use
      
      # Persistent applications in dock (in order)
      persistent-apps = [
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
      ];
    };
    
    # Finder Configuration
    finder = {
      FXPreferredViewStyle = "clmv";        # Column view by default
      _FXSortFoldersFirst = true;           # Show folders first
      AppleShowAllExtensions = true;        # Show all file extensions
      FXDefaultSearchScope = "SCcf";        # Search current folder by default
      ShowPathbar = true;                   # Show path bar
      ShowStatusBar = true;                 # Show status bar
    };
    
    # Control Center Configuration
    controlcenter = {
      BatteryShowPercentage = true;         # Show battery percentage
    };
    
    # Login Window Configuration
    loginwindow = {
      GuestEnabled = false;                 # Disable guest user
    };
    
    # Global Domain Settings
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";         # Use dark mode
      AppleShowAllExtensions = true;        # Show file extensions globally
    };
    
    # Custom Application Preferences
    CustomUserPreferences = {
      
      # Global WebKit Settings
      NSGlobalDomain = {
        WebKitDeveloperExtras = true;       # Enable web inspector in web views
      };
      
      # Finder Extended Settings
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowRemovableMediaOnDesktop = true;
        AppleShowAllFiles = true;             # show all hidden files, Command+shift+. to toggle
      };
      
      # Desktop Services Configuration
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;    # No .DS_Store on network volumes
        DSDontWriteUSBStores = true;        # No .DS_Store on USB volumes
      };
      
      # Screen Capture Settings
      "com.apple.screencapture" = {
        location = "~/Desktop";             # Save screenshots to Desktop
        type = "png";                       # Use PNG format
      };
      
      # Privacy and Advertising
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      
      # Printing Preferences
      "com.apple.print.PrintingPrefs" = {
        "Quit When Finished" = true;       # Auto-quit printer app
      };
      
      # Software Update Settings
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;       # Check for updates automatically
        ScheduleFrequency = 1;              # Check daily
        AutomaticDownload = 1;              # Download updates automatically
        CriticalUpdateInstall = 1;          # Install security updates
      };
      
      # Time Machine Settings
      "com.apple.TimeMachine" = {
        DoNotOfferNewDisksForBackup = true;
      };
      
      # Image Capture Settings
      "com.apple.ImageCapture" = {
        disableHotPlug = true;              # Don't auto-open Photos
      };
      
      # App Store Settings
      "com.apple.commerce" = {
        AutoUpdate = true;                  # Auto-update apps
      };
    };
  };
}