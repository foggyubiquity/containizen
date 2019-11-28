# Containizen
> Max Security Minimal Footprint Base Containers

These images are lightweight by design with the following features:

- Built in the Cloud for the Cloud
- Rebuilt every 24 hours with the latest security patches
- Crafted with [NixPkgs Community](https://nixos.org/nixpkgs/)
- Extensible via DockerFile / OCI / Nix Build
- [Skarnet S6](https://skarnet.org/software/s6/) Supervision Suite for safe Process Zero+ management
- Optimal use of OCI Layers to maximise Caching & minimise update footprint

## How to Use
These images automatic start baked in according to each language's best practice. Should arguments be supplied to `CMD` they will override this autostart functionality automatically.

### NodeJS
* NPM is unnecessary for production code execution & can be dropped from the container. Containizen provides both variations for compatibility reasons.
* *Auto Start*: scans `package.json` for `scripts.start` & executes the value.

### Python
* Itamar has some excellent suggestions https://pythonspeed.com/articles/pipenv-docker/ for running Python within a container.
* `requirements.in` & `requirements.txt` should generally be used in images
* `pip-tools` as part of the development workflow
* `setuptools` can be useful for installing the developed application https://chriswarrick.com/blog/2014/09/15/python-apps-the-right-way-entry_points-and-scripts/
* `pip` to actually install requirements & application in the container via `requirements.txt` & `setup.py`
* *Auto Start*: scans `setup.py` for `setup(name=xxxx` and executes via `python -m xxxx`

## Extending

`extending/example.*` are available to understand how Nix could be used to extend these base images.

- `extending/example.sh` downloads a specified base image into the current directory
- `nix-build extending/example.nix` creates the usual `result` linking to a `tar.gz` image

## Updates

Repository is typically only updated in one of the following situations:

- New language support
- Critical functionality
- Key dependency requires it i.e. S6
- NixOS new version (Every 6 months)

Images are rebuilt and published to DockerHub _every 24 hours_ automatically.

## Open Containers Specification

Labels are respected, for those unfamiliar all built containers _should_ have these [annotations](https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys) applied. Containizen populates with information relevant to its generated base image only. Annotations should be overwritten when extending / using.

## Data Volumes
- Good practice is to ensure a common group for data mounts to share between containers & machines.
- Containizen is optimized for GID=328 or _dat_
- Containizen runs all applications by default as UID=289 or _ctz_
- Default volume is `/data` (following the widely used _common_ container data mount point)

## Gotchas

- `/tmp` does *not* exist in this base image as it should be mounted at runtime via `TMPFS` (Docker) or `emptyDir` (in Kubernetes)
- `/bin/sh` or `/bin/bash` are not available by default. *sh* is not cross-architecture compatible & introduces security issues. To comply with Cloud Native _(executable containers for any architecture)_ `execlineb` as part of `Skarnet S6` is used. For more information on `sh` issues & challenges see [Skarnet's Post](https://skarnet.org/software/execline/dieshdiedie.html). For more information about using `execlineb` easily see [Just Containers Explainer](https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks) or [Danny Spinellas's Getting Started](https://danyspin97.org/blog/getting-started-with-execline-scripting/)
- `root` is required for S6, but privileges are dropped for application execution. A default user `containizen` of uid:101, gid:101 is available. Additional users & groups can be added via the standard `useradd` & `groupadd` commands
- Read-Only File-System compatible. `/tmp` & `/var` are both volumes & expect `tmpfs` File-Systems to be mounted. While its possible to run this without Read-Only set, bear in mind both `/tmp` & `/var` are ephemeral.

## Further Work (PR Welcome)

- Easy Pinning of NixPkgs version that Base Images were built against for those using Nix to extend base images
- musl support: already available in Nix [Cross Compiling](https://matthewbauer.us/blog/beginners-guide-to-cross.html)
- Cache nix/store in CloudBuild
- S6 Automatically execute & monitor Goss
- Other Languages
