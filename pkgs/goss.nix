{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "goss-${version}";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "aelsabbahy";
    repo = "goss";
    rev = "v${version}";
    sha256 = "0abfrsnyw0g5fpcn2rbl619sqq0r9r1252mhyq5sg0s8vbz1j7la";
  };

  modSha256 = "0n4xvljzzfrq3sagdhj5g8p49wdkzk0f9iw8493z96lpn2db0sqz";
  # go: cannot determine module path for source directory /build/source (outside GOPATH, no import comments)
  # https://github.com/golang/go/issues/27951#issuecomment-493617872

  subPackages = [ "cmd/goss" ];
}
