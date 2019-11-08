FROM gcr.io/makisu-project/makisu:latest AS makisu

FROM nixorg/nix:latest as nix
COPY --from=makisu /makisu-internal /makisu-internal

RUN nix-channel --add https://nixos.org/channels/nixos-19.09 nixpkgs
RUN nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable
RUN nix-channel --update

ENTRYPOINT ["/makisu-internal/makisu"]
