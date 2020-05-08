{ pkgManager ? "none"
, ver ? "11"
, pkgs ? import ../../../nix
}:
with pkgs;
let
  language = pkgs.${toNix};
  toNix = "adoptopenjdk-openj9-bin-${ver}";
in
mkShell rec
{
  name = "impureEnv";
  buildInputs = [
    language
  ];
}
