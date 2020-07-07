let
  sources = import ../nix/sources.nix;
  callPackage = (import sources.nixpkgs { }).callPackage;
in
import sources.nixpkgs {
  overlays = [
    (final: prev: {
      dockerTools = (import sources.pinnedDockerTools { }).dockerTools;
      k6 = prev.k6.overrideAttrs (old: {
        name = "patched-k6-${old.version}";
        src = sources.k6;
      });
      goss = callPackage
        ./goss.nix { inherit sources; };
      s6-overlay = sources.s6-overlay;
      vulnix = callPackage sources.vulnix { };
    })
  ];
  config = {
    allowUnfree = true;
  };
}
