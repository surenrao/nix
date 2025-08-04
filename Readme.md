
## Install
Home Manager Bootstrap: On a fresh system, you might need to bootstrap Home Manager first: 
> nix-shell -p home-manager home-manager switch --flake .#yourusername@your-macbook-pro

## Update
To update all inputs defined in your flake.nix and update the flake.lock file accordingly, run:
> nix flake update

## Building
> darwin-rebuild build --flake ~/nix#m4max

## Running
> darwin-rebuild switch --flake ~/nix#m4max
