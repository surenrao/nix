{
  description = "Python development environment";

  outputs = { self, args }: {
    devShells."m4max-python" = devenv.lib.devShell {
      name = "python";
      description = "Python development shell for M4 Max";
      
      inputs = {
        nixpkgs = self.inputs.nixpkgs;
        flake-utils = self.inputs.flake-utils;
        devenv = self.inputs.devenv;
      };
      
      buildInputs = [
        # Use a specific Python version (3.12 in this example)
        self.inputs.devenv.devenv.python312
      ];
    };
  };
}
