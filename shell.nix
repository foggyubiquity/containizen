{ pkgs ? import ./nix }:

with pkgs;
with python3Packages;
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

    # Normal NixPkgs
    adoptopenjdk-openj9-bin-11
    execline
    nodejs
    act
  ];

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ./shell.sh;
}
