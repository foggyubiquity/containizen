{ buildGoModule, sources }:

buildGoModule rec {
  name = "goss-${version}";
  version = sources.goss.version;

  src = sources.goss;

  modSha256 = "0n4xvljzzfrq3sagdhj5g8p49wdkzk0f9iw8493z96lpn2db0sqz";
  # go: cannot determine module path for source directory /build/source (outside GOPATH, no import comments)
  # https://github.com/golang/go/issues/27951#issuecomment-493617872

  subPackages = [ "cmd/goss" ];
}
