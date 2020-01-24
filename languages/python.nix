{ ver ? null
, pkgs ? import (
    fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz
  ) { config = { allowUnfree = true; }; }
}:

let
  #######################
  # Configuration       #
  #######################

  buildInfo = {
    packages = [];
    # Ensure that any pkgs called / referenced in 'config' are specifically declared in the packages for layered-image to keep last layer minimal
    config = import ./python-config.nix {
      inherit language pkgs;
    };
    name = "foggyubiquity/containizen";
    tag = if ver == null then "python3" else "python${ver}";
  };

  language = {
    toNix = if ver == null then "python3" else "python${ver}";
    pkg = pkgs.${language.toNix};
  };

  #######################
  # Build Image Code    #
  #######################

in
pkgs.callPackage ../common.nix { inherit buildInfo pkgs language; }
