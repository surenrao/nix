{ pkgs, config, ... }:

{
  # Basic package definitions
  packages = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
  ];

  # Environment variables
  env = {
    PYTHON_KEYRING_BACKEND = "keyring.backends.null.Keyring";
  };

  # Languages configuration
  languages.python = {
    enable = true;
    package = pkgs.python3;
  };

  # Scripts for common tasks
  scripts = {
    "test" = {
      exec = "python -m pytest";
      description = "Run tests with pytest";
    };
    "format" = {
      exec = "python -m black .";
      description = "Format code with black";
    };
    "lint" = {
      exec = "python -m flake8 .";
      description = "Lint code with flake8";
    };
  };

  # Development shell hooks
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

  # Pre-commit hooks for code quality
  pre-commit.hooks = {
    black.enable = true;
    flake8.enable = true;
  };
}