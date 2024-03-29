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
    packages = [ ];
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
        pkgs =
          if pkgManager == "bundled" then
            with language.extra.pythonPackages; [ pip ] else
            with language.extra.pythonPackages; [ ];
        pythonVer = "python${ver}Packages";
        # TODO: push the bash path into a strategic file so docker run xxxx bash cannot easily happen in production
        paths = ":${pkgs.bash}/bin" + (if pkgManager == "bundled" then with language.extra.pythonPackages; ":${pip}/bin" else "");
      };
    pip = if pkgManager == "bundled" then "-pip" else "";
    pkg = pkgs.${language.toNix};
    # TODO python3Minimal is the only one available in NixPkgs, pinned to 3.7. It should be extended to allow newer version
    # toNix = if pkgManager == "none" then "python${ver}Minimal" else "python${ver}Full";
    toNix = if pkgManager == "none" then "python3Minimal" else "python${ver}Full";
  };

  #######################
  # Build Image Code    #
  #######################
in
if vulnix == null then
  pkgs.callPackage ../../common/default.nix { inherit buildInfo pkgs language; }
else
  pkgs.callPackage ../../vulnix.nix { inherit buildInfo pkgs language; }
