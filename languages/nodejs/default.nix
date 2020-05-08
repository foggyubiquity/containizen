{ pkgManager ? "none"
, vulnix ? null
, ver ? null
}:
let
  pkgs = import ../../nix;
  #######################
  # Configuration       #
  #######################
  buildInfo = {
    packages = with pkgs; [ jq ];
    # Ensure that any pkgs called / referenced in 'config' are specifically declared in the packages for layered-image to keep last layer minimal
    config = import ./config.nix {
      inherit language pkgs pkgManager;
    };
    name = "foggyubiquity/containizen";
    tag = "nodejs-v${ver}${language.npm}";
  };
  language = {
    extra =
      {
        pkgs = [ ];
        paths = if pkgManager == "bundled" then ":${pkgs.bash}/bin" else "";
      };
    npm = if pkgManager == "bundled" then "-npm" else "";
    pkg = pkgs.${language.toNix};
    slim = if pkgManager == "none" then "-slim" else "";
    toNix = if ver == null then "nodejs${language.slim}" else "nodejs${language.slim}-${ver}_x";
  };

  #######################
  # Build Image Code    #
  #######################
in
if vulnix == null then
  pkgs.callPackage ../../common/default.nix { inherit buildInfo pkgs language; }
else
  pkgs.callPackage ../../vulnix.nix { inherit buildInfo pkgs language; }
