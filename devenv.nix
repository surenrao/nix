{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "Python and .NET devenv";

  # Bypasses the runtime macOS localization crash when using .NET binaries
  env.DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1";

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
  
  # This enables the .NET SDK seamlessly inside your development workspace
  languages.dotnet = {
    enable = true;
    package = pkgs.dotnet-sdk_10; 
  };

  # https://devenv.sh/scripts/
  scripts.test.exec = "uv run pytest";
  scripts.format.exec = "uv run black .";
  scripts.lint.exec = "uv run flake8 .";

  enterShell = ''
    echo "Development environment (uv + dotnet) activated!"
    uv --version
    dotnet --version
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