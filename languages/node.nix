{ ver ? null
, withNPM ? "false"
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
    config = import ./node-config.nix {
      inherit language pkgs withNPM;
    };
    name = "sotekton/containizen";
    tag = if ver == null then "nodejs${language.npm}" else "nodejs${ver}${language.npm}";
  };

  language = {
    toNix = if ver == null then "nodejs${language.slim}" else "nodejs${language.slim}-${ver}_x";
    pkg = pkgs.${language.toNix};
    slim = if withNPM == "false" then "-slim" else "";
    npm = if withNPM == "true" then "-npm" else "";
  };

  #######################
  # Build Image Code    #
  #######################

in
pkgs.callPackage ../common.nix { inherit buildInfo pkgs language; }
