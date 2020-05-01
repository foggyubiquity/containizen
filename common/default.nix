{ buildInfo
, language
, pkgs
}:
let
  # path = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${goss}/bin:${language.pkg}/bin";
  # Nix - root - Specific Paths (to avoid confusion in mappings)
  path = "PATH=/usr/bin:/bin:${language.pkg}/bin" + "${language.extra.paths}";

  goss = pkgs.callPackage ../pkgs/goss.nix {};
  commonPkgs = pkgs.callPackage ./pkgs.nix {};
in
  #######################
  # Build Image Code    #
  #######################
pkgs.dockerTools.buildLayeredImage {
  name = buildInfo.name;
  tag = buildInfo.tag;

  contents = commonPkgs.nixpkgs
  ++ commonPkgs.localpkgs
  ++ commonPkgs.skawarePackages
  ++ [ language.pkg ]
  ++ [ language.extra.pkgs ] # TODO fix to array
  ++ buildInfo.packages;

  maxLayers = 104; # 128 is the maximum number of layers, leaving 24 available for extension
  config = buildInfo.config // {
    Env = buildInfo.config.Env ++ [ path ];
  };
  extraCommands = pkgs.callPackage ./image-extracommands.nix {};
}
