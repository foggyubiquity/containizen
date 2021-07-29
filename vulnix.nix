{ buildInfo
, language
, pkgs
}:
with pkgs;
let
  skaware = callPackage ./common/skaware.nix { inherit pkgs; };
in
stdenv.mkDerivation {

  buildInputs = skaware
    ++ [ (if (builtins.getEnv "GITHUB_ACTIONS") != "true" then goss else "") language.pkg ]
    ++ buildInfo.packages;
  name = "vulnerability-scan";
  src = "...";
  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  installPhase = ''
    mkdir -p $out/bin
  '';
}
