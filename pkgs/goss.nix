{ fetchurl, stdenv }:

let
  version = "v0.3.9";
in
stdenv.mkDerivation {
  name = "goss";
  src = fetchurl {
    url = "https://github.com/aelsabbahy/goss/releases/download/${version}/goss-linux-amd64";
    sha256 = "1j33arvp3050ppd26zz1psvb7wfrxqall6w5k77famgrq2l52jjy";
  };
  phases = [ "installPhase" "patchPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/goss
    chmod +x $out/bin/goss
  '';
}

# Some issues:
# Project currently between maintainers, original vs replacer, looks like still maintained but unsure
# Original project has issue with Go Modules, alternative has broken Goss Serve


# {buildGoModule, fetchFromGitHub}:

# buildGoModule rec {
#   name = "goss-${version}";
#   # version = "0.6.0";
#   version = "0.3.7";

#   src = fetchFromGitHub {
#     # owner = "SimonBaeumer";
#     owner = "aelsabbahy";
#     repo = "goss";
#     rev = "v${version}";
#     # sha256 = "1fmk1y2yy8wv3a1crkcripzdqb6dy1h1m62gcz5r50g2ncvb3k6k";
#     sha256 = "1vfpdg7d4j8f7lgzlkkax2yyyaqvzibx2crrnbisbvjwvmj2np4g";
#   };

#   preBuild = ''
#     ls -lart
#     go mod init `pwd`
#     '';
#   # modSha256 = "1z27ccwvb34y1rknwz9d6b03f33kjc0r7gzn6mg564brxbrnri2x";
#   modSha256 = "1z2rccwvb34y1rknwz9d6b03f33kjc0r7gzn6mg564brxbrnri2x";
#   # go: cannot determine module path for source directory /build/source (outside GOPATH, no import comments)
#   # https://github.com/golang/go/issues/27951#issuecomment-493617872

#   # subPackages = ["cmd/goss"];
# }
