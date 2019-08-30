{
  stdenv ? (import <nixpkgs> {}).stdenv
}:
let
  s6 = {
    version = "1.22.1.0";
    sha256 = "0dcbi7zxqa81wp0yail0xsmz2wrjwj661qsivqlqwyb5qb2j0g2y";
  };

in
  stdenv.mkDerivation rec {
    name = "s6-overlay";
    src = (builtins.fetchTarball {
      url = "https://github.com/just-containers/s6-overlay/releases/download/v${s6.version}/s6-overlay-amd64.tar.gz";
      sha256 = "${s6.sha256}";
    });
    phases = [ "installPhase" ];
    installPhase = ''
      cp -rs $src $out
    '';
  }

