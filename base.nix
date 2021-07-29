let
  pkgs = import ./nix;
  imgConfig = import ./common/config.nix {
    inherit pkgs;
  };
in
with pkgs;
dockerTools.buildLayeredImage {
  name = "foggyubiquity/containizen";
  tag = "base";
  contents = callPackage ./common/skaware.nix { };
  maxLayers = 104; # 128 is the maximum number of layers, leaving 24 available for extension
  config = imgConfig;
  extraCommands = callPackage ./common/image-extracommands.nix { };
  # TODO fakeRootCommands - check relevance
}
