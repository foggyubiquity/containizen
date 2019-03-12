FROM sotekton/basal:makisu

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update

ENTRYPOINT ["nix-build"]
