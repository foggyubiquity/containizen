{ pkgs ? import <nixpkgs> {}
, buildGoModule ? pkgs.buildGoModule
, lib ? pkgs.lib
, fetchFromGitHub ? pkgs.fetchFromGitHub
}:

buildGoModule rec {
  name = "makisu-${version}";
  version = "0.1.12";

  src = fetchFromGitHub {
    owner = "uber";
    repo = "makisu";
    rev = "v${version}";
    sha256 = "10x7n000wvnbkl5wayhwqry413x8ppnzlnbpc46lrmcqciq200g0";
  };

  modSha256 = "0yf3kmlw912m3yl68hhgk25ixnaxgca09k4sx5a7s96gwh2v9k1i";

  # subPackages = [ "." ];

  meta = with lib; {
    description = "Docker Neutral Container Builder";
    homepage = https://github.com/uber/makisu;
    # license = licenses.Apache-2.0;
    maintainers = with maintainers;
      [ Keidrych ];
    platforms = platforms.linux;
  };
}
