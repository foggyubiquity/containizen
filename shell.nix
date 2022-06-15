# Enforce CI & DirEnv to use identical packages
{ pkgs ? import ./nix }:
let
  ci = with builtins; (
    if stringLength (getEnv "CI") == 0 then
      if (getEnv "GITHUB_ACTOR") == "nektos/act" then true else false
    else
      true
  );
in
with pkgs;
with python3Packages;
# c toolchain unecessary - https://fzakaria.com/2021/08/02/a-minimal-nix-shell.html
# nixos package so still not included in approach
mkShell rec
{
  name = "impureEnv";
  venvDir = "./.venv";
  LC_ALL = "C";
  # nativeBuildInput = [ setuptools ];
  buildInputs = (
    if ci then [
      docker
      vulnix
      yj
      yq
    ] else [
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
      dive
    ]
  ) ++
  [
    # Common Packages
    niv
  ];

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ./shell.sh;
}
