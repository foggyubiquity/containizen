{ buildInfo
, language
, pkgs ? import <nixpkgs> {}
}:
let
  commonPkgs = pkgs.callPackage ../common-pkgs.nix { inherit pkgs; };
in
pkgs.stdenv.mkDerivation {

  buildInputs = commonPkgs.nixpkgs ++ commonPkgs.localpkgs ++ [ language.pkg ] ++ buildInfo.packages;

  name = "vulnerability-scan";
  src = "...";
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/bin
  '';
}
