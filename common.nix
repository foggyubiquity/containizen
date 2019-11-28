{ buildInfo ? null
, language ? null
, pkgs ? import <nixpkgs> { config = { allowUnfree = true; }; }
, unstable ? import <nixpkgs-unstable> { config = { allowUnfree = true; }; }
}:

let

  # Base Image should contain only the essentials to run the application in a container.
  # Alternatives to nologin are 'su' and 'shadow' (full suite)
  imagePackages = [ pkgs.coreutils pkgs.nologin pkgs.jq ];
  path = "PATH=/usr/bin:/bin:${goss}/bin:${language.package}/bin";
  start = builtins.readFile ./auto-start-language;

  #######################
  # Derivations         #
  #######################

  goss = pkgs.callPackage ./pkgs/goss.nix {};
  s6-overlay = pkgs.callPackage ./pkgs/s6-overlay.nix {};

  #######################
  # Build Image Code    #
  #######################


in
pkgs.dockerTools.buildLayeredImage {
  name = buildInfo.name;
  tag = buildInfo.tag;
  contents = imagePackages ++ buildInfo.packages ++ [ s6-overlay goss ];
  maxLayers = 104; # 128 is the maximum number of layers, leaving 24 available for extension
  config = (
    {
      Entrypoint = [ "/init" ];
    } // buildInfo.config // { Env = buildInfo.config.Env ++ [ path ]; }
  );
  extraCommands = ''
    # User Permissions
    mkdir -p ./opt/app ./root ./home/containizen ./etc/pam.d
    chmod 755 ./etc ./opt/app ./root ./home/containizen ./etc/pam.d
    echo "root:x:0:0::/root:/bin/nologin" > ./etc/passwd
    echo "containizen:x:289:308::/home/containizen:/bin/nologin" >> ./etc/passwd
    echo "root:!x:::::::" > ./etc/shadow
    echo "containizen:!:18226::::::" >> ./etc/shadow
    echo "root:x:0:" > ./etc/group
    echo "containizen:x:308:" >> ./etc/group
    echo "root:x::" > ./etc/gshadow
    echo "containizen:!::" >> ./etc/gshadow
    cat > ./etc/pam.d/other <<EOF
    account sufficient pam_unix.so
    auth sufficient pam_rootok.so
    password requisite pam_unix.so nullok sha512
    session required pam_unix.so
    EOF

    chmod 0555 ./etc/passwd ./etc/shadow ./etc/group ./etc/gshadow ./etc/pam.d/other ./etc/pam.d

    # Runtime Fix Attributes
    mkdir -p ./etc/fix-attrs.d
    chmod 755 ./etc/fix-attrs.d
    cat > ./etc/fix-attrs.d/00-boot <<EOF
    /opt/app true containizen 0644 0755
    EOF
    chmod 0644 ./etc/fix-attrs.d/00-boot

    # /start app auto launcher
    cat > ./start <<EOF
    ${start}
    EOF
    chmod 775 ./start
  '';
}
