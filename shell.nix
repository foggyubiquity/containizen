{ pkgs ? import (
    fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/${pkgsPinned}.tar.gz"
  ) {
    config = { allowUnfree = true; };
  }
, pkgsPinned ? "nixpkgs-unstable"
}:

with pkgs; with python3Packages;
let
  re-act = callPackage ./pkgs/act.nix {};
in
mkShell rec
{
  name = "impureEnv";
  venvDir = "./.venv";
  LC_ALL = "C";
  # nativeBuildInput = [ setuptools ];
  buildInputs = [
    # A python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    python3Minimal
    # This execute some shell code to initialize a venv in $venvDir before
    # dropping into the shell
    venvShellHook
    pip
    # pip-tools

    # Normal NixPkgs
    execline
    nodejs
    re-act
  ];

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ./shell.sh;
}
