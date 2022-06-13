{ pkgs ? import ../../../nix
, ver ? null
}:

with pkgs;
let
  pythonVer = "python${ver}Packages";
  pp = pkgs.${pythonVer};
  # TODO python3Minimal is the only one available in NixPkgs, pinned to 3.8. It should be extended to allow alternate versions
  language = "python${ver}Minimal";
  pythonLang = pkgs.${language};
in
mkShell rec
{
  name = "impureEnv";
  venvDir = "./.venv";
  LC_ALL = "C";
  buildInputs = with pp; [
    # A python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    python3Minimal
    # This execute some shell code to initialize a venv in $venvDir before
    # dropping into the shell
    venvShellHook
    pip
    # pip-tools can't currently be used from NIX as pip-sync tries to remove setuptools-scm which fails due to read only filesystem

    # NixPkgs
  ];
}
