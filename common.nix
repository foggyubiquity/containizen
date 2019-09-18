{
  buildInfo ? null,
  language ? null,
  pkgs ? import <nixpkgs> {
    overlays = [ (self: super: {
    # Allow unstable libraries if newer versions are of software are needed
    unstable = import (
      fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz
      ) { config = { allowUnfree = true; }; };
    }
    ) ];
  }
}:

let

# Base Image should contain only the essentials to run the application in a container.
# Alternatives to nologin are 'su' and 'shadow' (full suite)
imagePackages = [ pkgs.coreutils pkgs.nologin pkgs.bash ];
path = "PATH=/usr/bin:/bin:${language.package}/bin";

#######################
# Build Image Code    #
#######################

s6-overlay = pkgs.callPackage ./s6-overlay.nix {};

in
  pkgs.dockerTools.buildLayeredImage {
    name = buildInfo.name;
    tag = buildInfo.tag;
    contents = imagePackages ++ buildInfo.packages ++ [ s6-overlay ];
    maxLayers = 104; # 128 is the maximum number of layers, leaving 24 available for extension
    config = ({
      Entrypoint = [ "/init" ];
    } // buildInfo.config // { Env = buildInfo.config.Env ++ [ path ]; });
    extraCommands = ''
      chmod 755 ./etc
      echo "root:x:0:0::/root:${pkgs.bash}" > ./etc/passwd
      chmod 0555 ./etc/passwd
      echo "root:!x:::::::" > ./etc/shadow
      chmod 0555 ./etc/shadow
      echo "root:x:0:" > ./etc/group
      chmod 0555 ./etc/group
      echo "root:x::" > ./etc/gshadow
      chmod 0555 ./etc/gshadow
      mkdir -p ./etc/pam.d
      chmod 755 ./etc/pam.d
      cat > ./etc/pam.d/other <<EOF
      account sufficient pam_unix.so
      auth sufficient pam_rootok.so
      password requisite pam_unix.so nullok sha512
      session required pam_unix.so
      EOF
      chmod 0555 ./etc/pam.d/other
      chmod 0555 ./etc/pam.d
      ln -s "${pkgs.bash}/bin/bash" ./bash
      mkdir -p ./opt/app
    '';
  }
