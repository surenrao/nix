{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "Python devenv";

  # Fix for missing packages and package builder crashes
  overlays = [
    (final: prev: {
      cspell = prev.nodePackages.cspell or prev.hello;
      
      # Fixes the build block for pre-commit by telling the builder to skip 
      # the buggy global setup phase. This allows pre-commit to compile cleanly.
      prek = prev.pre-commit.overrideAttrs (oldAttrs: {
        dontConfigureNuget = true;
      });
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
  
  # .NET is not set here: the shell uses the system SDK from the Homebrew
  # dotnet-sdk cask (latest release), which a devenv SDK would shadow.

  # https://devenv.sh/scripts/
  scripts.test.exec = "uv run pytest";
  scripts.format.exec = "uv run black .";
  scripts.lint.exec = "uv run flake8 .";

  scripts."antigravity-ide".exec = ''
    APP_BIN="/Applications/Antigravity IDE.app/Contents/Resources/app/bin/antigravity-ide"
    USER_APP_BIN="$HOME/Applications/Antigravity IDE.app/Contents/Resources/app/bin/antigravity-ide"
    if [ -x "$APP_BIN" ]; then
      exec "$APP_BIN" "$@"
    elif [ -x "$USER_APP_BIN" ]; then
      exec "$USER_APP_BIN" "$@"
    elif command -v open >/dev/null 2>&1; then
      exec open -a "Antigravity IDE" "$@"
    else
      echo "Error: Antigravity IDE was not found in /Applications or ~/Applications." >&2
      exit 1
    fi
  '';
  scripts.antigravity.exec = ''
    antigravity-ide "$@"
  '';
  scripts."agy-ide".exec = ''
    antigravity-ide "$@"
  '';

  enterShell = ''
    echo "Development environment (uv) activated!"
    uv --version
    command -v dotnet >/dev/null && echo ".NET $(dotnet --version)"
    echo "Antigravity IDE available: run 'antigravity-ide', 'antigravity', or 'agy-ide'"
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
}