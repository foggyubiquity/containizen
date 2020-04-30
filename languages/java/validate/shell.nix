{ pkgs ? import (
    fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/${pkgsPinned}.tar.gz"
  ) {
    config = { allowUnfree = true; };
  }
, pkgsPinned ? "nixpkgs-unstable"
, ver ? "11"
, pkgManager ? "none"
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
