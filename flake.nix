{
  description = "JupyterLab Flake for Stable Diffusion";

  inputs = {
    jupyterWith.url = "github:tweag/jupyterWith";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    jupyterWith,
    flake-utils,
  }:
    flake-utils.lib.eachSystem ["x86_64-linux"] (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = nixpkgs.lib.attrValues jupyterWith.overlays;
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

      jupyterEnvironment = pkgs.jupyterlabWith {kernels = [iPython];};
    in rec {
      apps.jupyterLab = {
        type = "app";
        program = "${jupyterEnvironment}/bin/jupyter-lab";
      };
      defaultApp = apps.jupterlab;
      devShell = jupyterEnvironment.env;
    });
}
