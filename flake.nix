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
        torch = pkgs.python310Packages.torch-bin;
      };

      iPython = pkgs.kernels.iPythonWith {
        name = "Python-env";
        packages = p: with p; [diffusers transformers];
        ignoreCollisions = true;
      };

      jupyterEnvironment = pkgs.jupyterlabWith {
        kernels = [iPython];
      };
    in rec {
      jupyterWrapped = pkgs.writeShellScriptBin "jupyter" ''
        #!/bin/sh
        ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${jupyterEnvironment}/bin/jupyter-lab "$@"
      '';
      apps.jupyterLab = {
        type = "app";
        program = "${jupyterWrapped}/bin/jupyter";
      };
      defaultApp = apps.jupyterLab;
      devShell = jupyterEnvironment.env;
    });
}
