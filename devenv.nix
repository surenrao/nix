{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "Python devenv";

  # Fix for missing cspell in older nixpkgs pin
  overlays = [
    (final: prev: {
      cspell = prev.nodePackages.cspell or prev.hello;
    })
  ];

  # https://devenv.sh/packages/
  packages = [
    pkgs.nodejs
    pkgs.uv
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    uv.enable = true;
    uv.sync.enable = true;
  };
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs;
  };

  # https://devenv.sh/scripts/
  scripts.test.exec = "uv run pytest";
  scripts.format.exec = "uv run black .";
  scripts.lint.exec = "uv run flake8 .";

  enterShell = ''
    echo "Python development environment (uv-managed) activated"
    uv --version
  '';

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    python --version
  '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    black.enable = true;
    flake8.enable = true;
  };

  # See full reference at https://devenv.sh/reference/options/
}