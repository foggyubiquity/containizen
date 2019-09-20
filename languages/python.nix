{
  ver ? null,
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
  ];
    # Cmd must be specified as Nix strips any prior definition out to ensure clean execution
    Cmd = [
    ];
    WorkingDir = "/opt/app";
  };
  name = "sotekton/basal";
  tag = if ver == null then "python3" else "python${ver}";
};

language = {
  toNix = if ver == null then "python3" else "python${ver}";
  package = pkgs.${language.toNix};
};

#######################
# Build Image Code    #
#######################

in
  pkgs.callPackage ../common.nix {inherit buildInfo pkgs language;}
