{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "Python devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.black
    python3Packages.flake8
    python3Packages.pytest
    nodejs
  ];

  # https://devenv.sh/languages/
  languages.python = {
    enable = true;
    package = pkgs.python3;
  };
  languages.javascript = {
    enable = true;
    package = pkgs.nodejs;
  };

  # https://devenv.sh/scripts/
  scripts.test.exec = "python -m pytest";
  scripts.format.exec = "black .";
  scripts.lint.exec = "flake8 .";

  enterShell = ''
    echo "Python development environment activated"
    echo "Python version: $(python --version)"
    echo "Pip version: $(pip --version)"
    
    # Create a virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating virtual environment..."
      python -m venv .venv
      source .venv/bin/activate
      pip install --upgrade pip
    fi
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
