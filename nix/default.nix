let
  sources = import ./sources.nix;
  callPackage = (import sources.nixpkgs { }).callPackage;
in
import sources.nixpkgs {
  overlays = [
    (
      final: prev: {
        # Strip Locale's from built container for non-used languages (~15Mb space reduction) - override glibc allLocales - override glibcLocales may be better
        # Requires full recompile of glibc which takes hours on github actions
        # omitted at this time to save minutes
        # glibc = prev.glibc.overrideAttrs
        #   (
        #     old: {
        #       allLocales = "C.UTF-8";
        #       locales = "C.UTF-8";
        #     }
        #   );
        k6 = prev.k6.overrideAttrs (
          old: {
            name = "patched-k6-${old.version}";
            src = sources.k6;
          }
        );
        goss = callPackage
          ./goss.nix
          { inherit sources; };
        s6-overlay-noarch = sources.s6-overlay-noarch;
        # TODO syslogd-overlay
        # https://github.com/just-containers/s6-overlay/blob/master/MOVING-TO-V3.md
        s6-overlay-x86_64 = sources.s6-overlay-x86_64;
        niv = (import sources.niv { }).niv;
      }
    )
  ];
  config = {
    allowUnfree = true;
    # replaceStdenv = { pkgs, ... }: pkgs.clangStdenv;
  };
}
