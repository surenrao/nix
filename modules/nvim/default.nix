# Neovim with LazyVim (https://www.lazyvim.org), managed by Home Manager.
#
# Neovim itself comes from modules/packages.nix. The config files in
# ./config (from the LazyVim starter) are linked one by one into
# ~/.config/nvim, so the folder itself stays writable: lazy.nvim writes
# lazy-lock.json there and :LazyExtras writes lazyvim.json. Those two are
# left out of the repo on purpose, so plugins update themselves (:Lazy).
#
# Edit the Lua files here, not in ~/.config/nvim (those are read-only
# links), then run `home-manager switch`.
{ pkgs, ... }: {
  xdg.configFile = {
    "nvim/init.lua".source = ./config/init.lua;
    "nvim/stylua.toml".source = ./config/stylua.toml;
    "nvim/.neoconf.json".source = ./config/.neoconf.json;
    "nvim/lua" = {
      source = ./config/lua;
      recursive = true; # link each file, keep the folders real
    };
  };

  # Tools LazyVim uses (:checkhealth lists them). git, ripgrep, fd, fzf
  # and curl are already in home.nix; the C compiler comes with Xcode.
  home.packages = with pkgs; [
    lazygit # git UI inside Neovim (<leader>gg)
    tree-sitter # CLI that nvim-treesitter uses to build parsers
  ];
}
