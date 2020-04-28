{ ver ? null
, withPIP ? "false"
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
    tag = "python-v${ver}${language.pip}";
  };

  language = {
    extra =
      {
        pythonPackages = pkgs.${language.extra.pythonVer};
        pkgs = with language.extra.pythonPackages; [ pip ];
        pythonVer = "python${ver}Packages";
        # TODO: push the bash path into a strategic file so docker run xxxx bash cannot easily happen in production
        paths = ":${pkgs.bash}/bin" + (if withPIP == "true" then with language.extra.pythonPackages; ":${pip}/bin" else "");
      };
    pip = if withPIP == "true" then "-pip" else "";
    pkg = pkgs.${language.toNix};
    # TODO python3Minimal is the only one available in NixPkgs, pinned to 3.7. It should be extended to allow newer version
    # toNix = if withPIP == "false" then "python${ver}Minimal" else "python${ver}Full";
    toNix = if withPIP == "false" then "python3Minimal" else "python${ver}Full";
  };

  #######################
  # Build Image Code    #
  #######################
in
if vulnix == null then
  pkgs.callPackage ../../common/default.nix { inherit buildInfo pkgs language; }
else
  pkgs.callPackage ../../vulnix.nix { inherit buildInfo pkgs language; }
