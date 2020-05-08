{ lib, buildGoModule, sources }:

buildGoModule rec {
  pname = "act";
  version = sources.act.version;

  src = sources.act;

  modSha256 = "09q8dh4g4k0y7mrhwyi9py7zdiipmq91j3f32cn635v2xw6zyg2k";

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "Run your GitHub Actions locally";
    homepage = "https://github.com/nektos/act";
    license = licenses.mit;
    maintainers = with maintainers; [ filalex77 ];
  };
}
