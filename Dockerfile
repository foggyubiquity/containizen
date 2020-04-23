FROM gcr.io/uber-container-tools/makisu:latest AS makisu

FROM nixorg/nix:latest as nix
COPY --from=makisu /makisu-internal /makisu-internal

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
# Stability Fix: --update can timeout on GitHub Actions as build doesn't use default nixpkgs channel this isn't critical
# when using this container interactively it is important to update the channels
# RUN nix-channel --update

# Alias commonly used alternate names
# Symlinks are still valid in NixOS & prevent file duplication / image bloat
# NOTE: nix-channel --update will remove these symlinks as channel link increases in number
# RUN ln -s $NIX_PATH/nixos-unstable $NIX_PATH/unstable
# RUN ln -s $NIX_PATH/nixos-unstable $NIX_PATH/nixpkgs-unstable
# RUN ln -s $NIX_PATH/nixos $NIX_PATH/nixpkgs

# Makisu can only build ontop of an existing base container.. will reset all files from there due to restrictions on Docker Run
# Buildah also has no viable solution for Docker Run
# NixOS must build the package so only the code is injected as files ontop of the base container for makisu compatibility
# In other words, this container needs all the dependencies already packaged

ENTRYPOINT ["/makisu-internal/makisu"]
