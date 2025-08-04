# Application Linking and Spotlight Integration
# Ensures Nix-installed applications appear in Spotlight and Launchpad
{ pkgs, config, ... }: {
  
  # Application linking script for Spotlight and Launchpad integration
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in
    pkgs.lib.mkForce ''
      # Set up applications for Spotlight and Launchpad integration
      echo "Setting up /Applications for Spotlight integration..." >&2
      
      # Clean up existing Nix Apps directory
      rm -rf /Applications/Nix\ Apps
      mkdir -p /Applications/Nix\ Apps
      
      # Create symbolic links for each application
      find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      while read -r src; do
        app_name=$(basename "$src")
        echo "Linking $src -> /Applications/Nix Apps/$app_name" >&2
        # Use symbolic links instead of aliases for better Spotlight integration
        ln -sf "$src" "/Applications/Nix Apps/$app_name"
      done
      
      # Force Spotlight to reindex the Applications folder
      echo "Reindexing Spotlight for Applications..." >&2
      /usr/bin/mdimport -r /Applications/Nix\ Apps/ || true
      
      # Register applications with Launch Services
      /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
        -f -R -domain local -domain system -domain user /Applications/Nix\ Apps/ || true
      
      echo "Application linking complete." >&2
    '';
}