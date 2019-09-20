{
  ver ? null,
  withNPM ? "false",
  pkgs ? import <nixpkgs> {
    overlays = [ (self: super: {
    # Allow unstable libraries if newer versions are of software are needed
    unstable = import (
      fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
      ) { config = { allowUnfree = true; }; };
    }
    ) ];
  }
}:

let

#######################
# Configuration       #
#######################

buildInfo = {
  packages = [
  ];
  # Ensure that any pkgs called / referenced in 'config' are specifically declared in the packages for layered-image to keep last layer minimal
  config = {
    Env = [
      "NODE_PATH=/node_modules"
      "NODE_ENV=production"
  ];
    # Cmd must be specified as Nix strips any prior definition out to ensure clean execution
    Cmd = if withNPM == "true"
    then [
      # Full NodeJS version also contains NPM, strictly not necessary for production deployments
      "${language.package}/bin/npm"
      "start"
    ]
    else [];
    WorkingDir = "/opt/app";
  };
  name = "sotekton/basal";
  tag = if ver == null then "nodejs${language.npm}" else "nodejs${ver}${language.npm}";
};

language = {
  toNix = if ver == null then "nodejs${language.slim}" else "nodejs${language.slim}-${ver}_x";
  package = pkgs.${language.toNix};
  slim = if withNPM == "false" then "-slim" else "";
  npm = if withNPM == "true" then "-npm" else "";
};

#######################
# Build Image Code    #
#######################

in
  pkgs.callPackage ./common.nix {inherit buildInfo pkgs language;}
