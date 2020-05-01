{ pkgs, callPackage }:
let
  #######################
  # Derivations         #
  #######################

  goss = callPackage ../pkgs/goss.nix {};
  s6-overlay = callPackage ../pkgs/s6-overlay.nix {};
  skawarePackages = with pkgs.skawarePackages; [ s6 s6-dns s6-linux-utils s6-portable-utils execline nsss ];
in
{
  nixpkgs = with pkgs; [ jq ] ++ skawarePackages;

  # localpkgs = [ goss ];
  localpkgs = [];
  inherit skawarePackages;
}
