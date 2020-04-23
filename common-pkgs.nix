{ pkgs }:
let
  #######################
  # Derivations         #
  #######################

  goss = pkgs.callPackage ./pkgs/goss.nix {};
  s6-overlay = pkgs.callPackage ./pkgs/s6-overlay.nix {};
in
{
  # Base Image should contain only the essentials to run the application in a container.
  # Alternatives to nologin are 'su' and 'shadow' (full suite)
  nixpkgs = with pkgs; [ coreutils nologin jq gnugrep ];

  localpkgs = [ goss s6-overlay ];
}
