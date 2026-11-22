# Homebrew Configuration
# Manages GUI applications and packages not available in nixpkgs
{ ... }: {
  
  homebrew = {
    enable = true;
    
    # Command-line tools via Homebrew
    brews = [
      "mas"              # Mac App Store command-line interface
      # All CLI/dev tools now managed via Nix for better reproducibility
      # Fonts (Nerd Fonts for terminal icons)
      # "font-fira-code"
      # "font-hack-nerd-font"
    ];
    
    # GUI Applications via Homebrew Casks
    # Apps with their own updater live here rather than in Nix: rebuilds install
    # them on a fresh machine, and the apps keep themselves up to date afterwards.
    casks = [
      # Development Tools
      "visual-studio-code" # Code editor (self-updating)

      # System Automation
      "hammerspoon"      # Desktop automation scripting using Lua

      # Media and Utilities
      "iina"             # Modern media player for macOS
      "the-unarchiver"   # Archive extraction utility
      "pearcleaner"      # Application uninstaller and cleaner

      # Productivity Tools
      "maccy"            # Clipboard manager
      "itsycal"          # Menu bar calendar

      # Creative Tools
      "inkscape"         # Vector graphics editor

      # Apps first installed by hand, now declared here. All have
      # auto_updates, so `brew bundle` adopts the existing copy in
      # /Applications (whatever its version) instead of reinstalling.
      # Careful: with cleanup = "zap", removing one later uninstalls the
      # app AND its data.
      "antigravity"      # Google Antigravity
      "antigravity-ide"  # Google Antigravity IDE
      "brave-browser"
      "claude"           # Claude desktop app
      "comfy"            # Comfy Desktop (cask was "comfyui")
      "dropbox"
      "firefox"
      "ghostty"          # Terminal
      "google-chrome"
      "google-gemini"    # Gemini desktop app (not the "gemini" cask)
      "resilio-sync"
      "scroll-reverser"
      "steam"
      "stremio"
      "telegram"         # Native macOS Telegram (ru.keepcoder.Telegram)
      "tor-browser"

      # No built-in updater: update these with `brew upgrade` now and then
      # (rebuilds never upgrade). `brew outdated` lists what's behind.
      # Adopting an existing copy needs the exact cask version, so if one
      # was installed by hand, remove it before adding it here.
      "bambu-studio"     # 3D printer slicer
      "blender"
      "godot-mono"       # Godot with C#
      "dotnet-sdk"       # The system .NET SDK (latest release); godot-mono needs it too
      # TEMPORARY: .NET 10 side by side for kosha-app (pinned there in
      # global.json). Remove once kosha-app is on .NET 11, along with
      # that global.json.
      "dotnet-sdk@10"
      "krita"
      "mozilla-vpn"      # .pkg; installs over an existing copy
      "rustdesk"         # Remote desktop
      "soulseek"
      "tiled"            # Tile map editor

      # Still manual (see manual-installs.txt): .pkg casks that would
      # reinstall over a self-updated copy (microsoft-teams would even
      # downgrade; tailscale-app); no cask for Hermes, Newshosting,
      # TurboTax, ZeroNet.
    ];

    # Mac App Store apps (the App Store keeps them updated). `brew bundle`
    # skips apps already installed, so on this Mac these are a no-op.
    # On a fresh Mac, sign in to the App Store first; `mas` installs have
    # failed during darwin-rebuild before, so if one does, install it from
    # the App Store by hand and rebuild again.
    masApps = {
      "GarageBand" = 682658836;
      "Hush" = 1544743900;               # Safari content blocker
      "iMovie" = 408981434;
      "Keynote" = 409183694;
      "Menu Bar Calendar" = 1558360383;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "PDFgear" = 6469021132;
      "SonicWall Mobile Connect" = 822514576;
      "Steam Link" = 1246969117;
      "WakeOnCommand" = 1484204619;
      "Windows App" = 1295203466;        # Microsoft Remote Desktop
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
    };

    # Homebrew Maintenance Settings
    # Rebuilds only install what's missing; apps update themselves and
    # anything without an updater can be upgraded manually with `brew upgrade`.
    onActivation = {
      cleanup = "zap";        # Remove unlisted packages
      autoUpdate = false;     # Don't refresh Homebrew on every rebuild
      upgrade = false;        # Don't upgrade packages on rebuild
    };
  };
}

# environment.extraInit = ''
#     export LM_STUDIO_API_KEY=dummy-api-key
#     export LM_STUDIO_API_BASE=http://localhost:1234/v1
#   '';