# Basal
> Max Security Minimal Footprint Base Containers

These images are lightweight by design with the following features:

- Built in the Cloud for the Cloud
- Rebuilt every 24 hours with the latest security patches
- Crafted with [NixPkgs Community](https://nixos.org/nixpkgs/)
- Extensible via DockerFile / OCI / Nix Build
- [Skarnet S6](https://skarnet.org/software/s6/) Supervision Suite for safe Process Zero+ management
- Optimal use of OCI Layers to maximise Caching & minimise update footprint

## Extending

`extending.example.*` are available to understand how Nix could be used to extend these base images.

- `extending.example.sh` downloads a specified base image into the current directory
- `nix-build extending.example.nix` creates the usual `result` linking to a `tar.gz` image

## Updates

Repository is only updated with critical functionality or when a key dependency requires it i.e. S6

Images are rebuilt and published to DockerHub every 24 hours automatically.

## Further Work (PR Welcome)

- Easy Pinning of NixPkgs version that Base Images were built against for those using Nix to extend base images
- musl support: already available in Nix [Cross Compiling](https://matthewbauer.us/blog/beginners-guide-to-cross.html)
- [DGoss](https://github.com/aelsabbahy/goss/tree/master/extras/dgoss) for execution-checks
- Python3
- Other Languages
