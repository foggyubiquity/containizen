{ buildInfo
, language
, pkgs
}:
with pkgs;
let
  # path = "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${goss}/bin:${language.pkg}/bin";
  # Nix - root - Specific Paths (to avoid confusion in mappings)
  path = "PATH=/usr/bin:/bin:${language.pkg}/bin"
    + "${language.extra.paths}"
    + ( if (builtins.getEnv "GITHUB_ACTIONS") != "true" then ":${goss}/bin" else "");
  skaware = callPackage ./skaware.nix {
    inherit pkgs;
  };
in
#######################
  # Build Image Code    #
  #######################
dockerTools.buildLayeredImage {
  name = buildInfo.name;
  tag = buildInfo.tag;
  contents = skaware
    ++ [ ( if (builtins.getEnv "GITHUB_ACTIONS") != "true" then goss else "") language.pkg ]
    ++ [ language.extra.pkgs ] # TODO fix to array
    ++ buildInfo.packages;
  maxLayers = 104; # 128 is the maximum number of layers, leaving 24 available for extension
  config = buildInfo.config // {
    Env = buildInfo.config.Env ++ [ path ];
  };
  extraCommands = callPackage ./image-extracommands.nix { };
}
