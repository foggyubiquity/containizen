{ localContainizen ? false
, fromContainizen ? "nodejs-slim"
, imageData ? {
    name = "sotekton/containizen";
    tag = "extended";
  }
, pkgs ? import <nixpkgs> { config = { allowUnfree = true; }; }
, # Allow unstable libraries if newer versions are of software are needed
  unstable ? import (
    fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz
  ) { config = { allowUnfree = true; }; }
}:

let

  #######################
  # Configuration       #
  #######################

  buildInfo = {
    language = pkgs."${fromContainizen}";
    packages = [];
    # Ensure that any pkgs called / referenced in 'config' are specifically declared in the packages for layered-image to keep last layer minimal
    config = {
      Env = [
        "NODE_PATH=/node_modules"
        "NODE_ENV=development"
      ];
      # Cmd must be specified as Nix strips any prior definition out to ensure clean execution
      Cmd = [
        "${buildInfo.language}/bin/node" # assuming the same NixPkgs version used to build both Base Image & this one or additional paths may be introduced extraneously into the store
      ];
      WorkingDir = "/opt/app";
    };
    name = imageData.name;
    tag = "${imageData.tag}";
  };

  # Production should contain only the essentials to run the application in a container.
  additonalPackages = [ pkgs.htop ];
  # extend path with additional locations if necessary
  path = "PATH=/usr/bin:/bin:${buildInfo.language}/bin";

  #######################
  # Build Image Code    #
  #######################

in
  # TODO switch to buildLayeredImage to optimize caching, requires merging the two images
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/docker/default.nix contains all available attributes.
pkgs.dockerTools.buildImage {
  created = "now"; # Current TimeStamp instead of layeredImage epoch + 1 (for caching)
  name = buildInfo.name;
  tag = buildInfo.tag;
  fromImage = if localContainizen then "${./result}" else "${./containizen.tar}";
  contents = additonalPackages;
  # Nix is building the container in a workspace, links should always be ./ which will result in / in the final container
  extraCommands = ''
    '';
  config = (
    {
      # https://docs.docker.com/engine/api/v1.30/#operation/ContainerCreate
      # Don't override S6 from upstream image as process 0 manager
      Entrypoint = [ "/init" ]; # Nix recreates manifest.json so settings to preserve must be re-specified
    } // buildInfo.config // { Env = buildInfo.config.Env ++ [ path ]; }
  );
}
