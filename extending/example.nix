{ localContainizen ? false
, fromContainizen ? "nodejs-slim"
, imageData ? {
    name = "foggyubiquity/containizen";
    tag = "extended";
  }
, pkgs ? import (
    fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz
  ) { config = { allowUnfree = true; }; }
}:
let
  #######################
  # Configuration       #
  #######################

  configCommon = import ./example-config.nix {
    inherit language pkgs pkgManager;
  };

  buildInfo = {
    language = pkgs."${fromContainizen}";
    packages = [];
    # Ensure that any pkgs called / referenced in 'config' are specifically declared in the packages for layered-image to keep last layer minimal
    config = configCommon // {
      ExposedPorts = configCommon.ExposedPorts // {
        # "<port>/<tcp|udp>": {}
      };
      Env = configCommon.Env ++ [];
      Labels = configCommon.Labels // {
        # "from" = "containizen";
      };
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
  config = buildInfo.config;
}
