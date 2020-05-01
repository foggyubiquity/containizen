{ pkgs ? import (
    fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/${pkgsPinned}.tar.gz"
  ) { config = { allowUnfree = true; }; }
, pkgsPinned ? "nixpkgs-unstable"
}:
let
  imgConfig = import ./common/config.nix { inherit pkgs; };
  commonPkgs = pkgs.callPackage ./common/pkgs.nix {};
in
pkgs.dockerTools.buildLayeredImage {
  name = "foggyubiquity/containizen";
  tag = "base";
  # contents = with pkgs; [ nologin s6-overlay ];
  contents = commonPkgs.skawarePackages;
  maxLayers = 104; # 128 is the maximum number of layers, leaving 24 available for extension
  config = imgConfig;
  extraCommands = pkgs.callPackage ./common/image-extracommands.nix {};
}
