{ pkgs }:
with pkgs.skawarePackages; [
  execline
  nsss
  s6
  s6-dns
  s6-linux-utils
  s6-portable-utils
]
