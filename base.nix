{
  # vulnix whitelist should only contain what is necessary to build containizen
  genVulnixWhitelist ? false
}:
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
  contents = (if genVulnixWhitelist != false then
    # include packages necessary for extraction for vulnix whitelist as these are NOT bundled into containizen but show up as false positives
    with pkgs; [  ] else
    callPackage ./common/skaware.nix { });
  maxLayers = 104; # 128 is the maximum number of layers, leaving 24 available for extension
  config = imgConfig;
  extraCommands = (if genVulnixWhitelist != false then
    '''' else
    callPackage ./common/image-extracommands.nix { });
}
