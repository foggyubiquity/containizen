{ pkgs }:
# let
#   pkgs = import <nixpkgs> {
#   # NOTE layer 3, or 30mb is currently sacrified to NixOS glibc from stdenv, its most likely unecssary. The following explains where it comes from and potentially how to remove
#   # https://discourse.nixos.org/t/how-to-override-stdenv-for-all-packages-in-mkshell/10368/16
#   # config.replaceStdenv = { pkgs, ... }: pkgs.fastStdenv;
# };
with pkgs.skawarePackages; [
  execline
  nsss
  s6
  s6-dns
  s6-linux-utils
  s6-portable-utils
  s6-rc
]
