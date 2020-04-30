{ ver ? null
, pkgManager ? "none"
, pkgs ? import (
    fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/${pkgsPinned}.tar.gz"
  ) { config = { allowUnfree = true; }; }
, pkgsPinned ? "nixpkgs-unstable"
, vulnix ? null
}:
let
  #######################
  # Configuration       #
  #######################

  buildInfo = {
    packages = [];
    # Ensure that any pkgs called / referenced in 'config' are specifically declared in the packages for layered-image to keep last layer minimal
    config = import ./config.nix {
      inherit language pkgs;
    };
    name = "foggyubiquity/containizen";
    tag = "java-v${ver}${language.pkgManager}";
  };

  language = {
    extra =
      {
        # javaPackages = pkgs.${language.extra.pythonVer};
        # pkgs = with language.extra.pythonPackages; [ pip ];
        pkgs = [];
        # pythonVer = "python${ver}Packages";
        # TODO: push the bash path into a strategic file so docker run xxxx bash cannot easily happen in production
        # paths = ":${pkgs.bash}/bin" + (if pkgManager == "bundled" then with language.extra.pythonPackages; ":${pip}/bin" else "");
        paths = ":${pkgs.bash}/bin";
      };
    pkgManager = if pkgManager == "maven" then "-mvn" else "";
    # pip = if pkgManager == "bundled" then "-pip" else "";
    pkg = pkgs.${language.toNix};
    toNix = if pkgManager == "none" then "adoptopenjdk-jre-openj9-bin-${ver}" else "adoptopenjdk-openj9-bin-${ver}";
  };

  #######################
  # Build Image Code    #
  #######################
in
if vulnix == null then
  pkgs.callPackage ../../common/default.nix { inherit buildInfo pkgs language; }
else
  pkgs.callPackage ../../vulnix.nix { inherit buildInfo pkgs language; }
