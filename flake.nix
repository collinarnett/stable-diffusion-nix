{
  description = "JupyterLab Flake for Stable Diffusion";

  inputs = {
    jupyterWith.url = "github:tweag/jupyterWith";
    flake-utils.url = "github:numtide/flake-utils";
    nixgl.url = "github:guibou/nixGL";
  };

  outputs = {
    self,
    nixpkgs,
    jupyterWith,
    flake-utils,
    nixgl,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [nixgl.overlay] ++ (nixpkgs.lib.attrValues jupyterWith.overlays);
        config.allowUnfree = true;
      };

      accelerate = pkgs.python310.pkgs.callPackage ./accelerate.nix {};
      diffusers = pkgs.python310.pkgs.callPackage ./diffusers.nix {
        inherit accelerate;
        # Excluding this override leads to "cuda not found" errors.
        torch = pkgs.python310Packages.torch-bin;
      };

      iPython = pkgs.kernels.iPythonWith {
        name = "Python-env";
        packages = p: with p; [diffusers transformers ftfy];
        ignoreCollisions = true;
      };

      jupyterEnvironment = pkgs.jupyterlabWith {
        kernels = [iPython];
      };

      jupyterWrapped = pkgs.writeShellScriptBin "jupyter" ''
        #!/bin/sh
        ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${jupyterEnvironment}/bin/jupyter-lab "$@"
      '';
    in rec {
      checks.accelerate = accelerate;
      checks.diffusers = diffusers;
      apps.jupyterLab = {
        type = "app";
        program = "${jupyterWrapped}/bin/jupyter";
      };
      apps.default = apps.jupyterLab;
      devShells.default = jupyterEnvironment.env;
    });
}
