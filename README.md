# Containizen

> Max Security Minimal Footprint Base Containers

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/foggyubiquity/containizen/rebuild%20containizen?style=for-the-badge) ![Docker Pulls](https://img.shields.io/docker/pulls/foggyubiquity/containizen?style=for-the-badge)

These images are lightweight by design with the following features:

- Built in the Cloud for the Cloud
- Rebuilt every 24 hours with the latest security patches
- Crafted with [NixPkgs Community](https://nixos.org/nixpkgs/)
- Extensible via DockerFile / OCI / Nix Build
- [Skarnet S6](https://skarnet.org/software/s6/) Supervision Suite for safe Process Zero+ management
- Optimal use of OCI Layers to maximise Caching & minimise image roll-out time / update footprint
- Read Only File-System compatible

## How to Use

These images contain automatic start capabilities in accordance with each language's best practice.
Should arguments be supplied to `CMD` they will override this autostart functionality automatically.

NOTE: `RUN` should *never* be used in `Dockerfile`(s) as it places a hard requirement on Docker being present in the build pipeline. Preventing powerful tools such as `Kaniko` & `Makisu` from leveraging Kubernetes for builds. Containizen images utilize approaches that do *not* require `RUN`.

### NodeJS ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/foggyubiquity/containizen/nodejs?label=Latest%20Image%20Size&logo=Node.js&style=for-the-badge)

#### Versions

Maintained as per [Release / LTS Information](https://nodejs.org/en/about/releases/)

| tag | version | usage |
| --- | --- | --- |
| nodejs | v10.x | production |
| nodejs-v10 | v10.x | production |
| nodejs-v12 | v12.x | production |
| nodejs-npm | v10.x | development |
| nodejs-v10-npm | v10.x + npm | development |
| nodejs-v12-npm | v12.x + npm | development |

#### Production Usage

```dockerfile
ARG version=nodejs
FROM foggyubiquity/containizen:$version AS base

# node_modules should already be populated by running
# $> NODE_ENV=production npm ci
COPY . /opt/app
```

#### Detailed Example

[languages/nodejs/validate](./languages/nodejs/validate)

#### Notes

* standard version *nodejs* rolls forward when *NixPkgs* drops support for older versions
* NPM is unnecessary for production code execution & creates a significant attack footprint. NPM is omitted from the container by default, use *-npm* tag if you need it
* *Auto Start*: scans `package.json` for `scripts.start` & executes the value.

### Python ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/foggyubiquity/containizen/python?label=Latest%20Image%20Size&logo=Python&style=for-the-badge)

#### Versions

* Maintained in alignment with bugfix branches per [Status of Python Branches](https://devguide.python.org/#status-of-python-branches)
* For advice about [when to switch versions](https://pythonspeed.com/articles/major-python-release/)

| tag | version | usage |
| --- | --- | --- |
| python | v3.7.x | production |
| python-v37 | v3.7.x | production |
| python-v38 | v3.8.x | production |
| python-pip | v3.7.x | development |
| python-v37-pip | v3.7.x | development |
| python-v38-pip | v3.8.x | development |

#### Production Usage

```dockerfile
ARG version=python
FROM foggyubiquity/containizen:$version AS base

# .pyz compatible file should already be generated
# Any file *.pyz will auto trigger Python execution
COPY containizen.pyz /opt/app/
```

#### Detailed Example

[languages/python/validate](./languages/python/validate)

#### Notes

* **Python** has [many ways of packaging](https://stackoverflow.com/a/14753678), however most approaches expect an installation against the actual operating system & architecture, not a portable package-manager free install.
* *Wheel & Egg* are unsuitable as they require `pip install` & `RUN` in a DockerFile
* *Virtual Environments* are unnecessary redundancy when using Containers
* [*shiv* from LinkedIn](https://github.com/linkedin/shiv) provides as *fast* **zipapp** solution for reproducible builds. While this can be independent of Containers it also provides a safe bundling approach.
* `pip-tools` provides a well-respected hash & pinning ability for PyPi packages / requirements
* *Auto Start*: scans `setup.py` for `setup(name=xxxx` and executes via `./xxxx` as per *shiv* specification & [PEP 441](http://legacy.python.org/dev/peps/pep-0441/)

### Java ![Docker Image Size (tag)](https://img.shields.io/docker/image-size/foggyubiquity/containizen/java?label=Latest%20Image%20Size&logo=Java&style=for-the-badge)

#### Engine Information

* **OpenJDK**: AdoptJDK binaries are in use as [*OpenJDK* no longer provides JRE versions](https://bugs.openjdk.java.net/browse/JDK-8200132). While we *could* bundle a JRE from individual modules, AdoptJDK is most compatible with *Quarkus* when using *OpenJ9* JVM variant. 
* **GraalVM** is *not* expected to run in *production* containers, instead the *native-image* output should be deployed. Ironically *native-image* is currently optimized for *hotspot* over *OpenJ9*. 
* **GraalVM** *native-image* results should be compiled directly with `nixpkgs.dockerTools.buildLayeredImage` ontop of `base.nix` in the root of this project's repo as better support is possible than using a *Base Image*

#### Versions

Maintained per [Release / LTS Information](https://adoptopenjdk.net/support.html)

**Java** tag means: Headless Java Release Compile (JRE) of OpenJDK via AdoptOpenJDK official binaries with OpenJ9 Java Virtual Machine (JVM)

| tag | version | usage |
| --- | --- | --- |
| java | v11.x | production |
| java-v8 | v8.x | production |
| java-v11 | v11.x | production |
| graal | v19.x | unavailable - waiting for NixPkgs support |
| graal-v19 | v19.x | unavailable - waiting for NixPkgs support |

#### Production Usage

```dockerfile
ARG version=java
FROM foggyubiquity/containizen:$version AS base

# .jar compatible file should already be generated
# Any file *.jar will auto trigger Python execution
COPY containizen.jar /opt/app/
```
#### Detailed Example

[languages/java/validate](./languages/java/validate)

#### Notes

* *Java* default is *v11* to co-align with *Foggy Development* and container optimized workloads. This allows easy support for frameworks such as *Spring Boot, Micronaut & Quarkus* to switch between *Java* & *GraalVM*
* *GraalVM Enterprise Edition* can be dropped in as an alternative to *Community Edition* (used in these images) however due to licensing requirements it must be installed manually.

## Built-in Security

* C Libraries are *SymLinked* as per NixPkgs approach ensuring global search of *all* libraries used in the image via [Docker Dive](https://github.com/wagoodman/dive)
* *Shadow*'s Name Service Switch replaced with *NSSS* for [reasons outlined](https://skarnet.org/software/nsss/nsswitch.html) & smaller attack footprint. `/etc/passwd`, `/etc/group` and `/etc/shadow` still used via `nsss-unix` over `nsss-switch` at this time (Future Optional Improvement)
* Automatically Dropped Permissions to `GID=328 or _dat_` and `UID=289 or _ctz_`
* Logging & all default writables are bound to `/tmp` as this would typically be bound via `TMPFS`. Everything else is a Read Only Operating System

## Validation

Containizen includes [goss](https://github.com/aelsabbahy/goss) for conducting `serverspec` validation on container start. While there are various approaches to using goss & external helpers such as `kgoss` (Kubernetes) or `dgoss` (Docker) executing goss directly within the container on start ensures all application requirements are specified correctly irrespective of the cloud providers or container management technology. Additionally as Containizen uses optimal layer caching & goss is bound to a specific layer there is no image update or propagation overhead beyond its growing the tar.gz size by ~5Mb.

TODO: (See further work) run tests prior to application start should `goss.yaml` be present in application directory

## Extending

`extending/example.*` are available to understand how Nix could be used to extend these base images.

- `extending/example.sh` downloads a specified base image into the current directory
- `nix-build extending/example.nix` creates the usual `result` linking to a `tar.gz` image

## Updates

Repository is typically only updated in one of the following situations:

- New language support
- Critical functionality
- Key dependency requirements i.e. S6
- Language LTS bump i.e. NodeJS 0.10.x -> 0.12.x

Images are rebuilt and published to DockerHub _every 24 hours_ automatically.

### NixOS Channel

* Following: *NixPkgs-Unstable*
* Understanding [Stable vs Unstable](https://nixos.wiki/wiki/Nix_channels). While the latest *stable* channel could have been used (and has been in the past) for just security patches. Feedback from the community has been to utilize *unstable* channel and specify package version. Guaranteeing security patches are applied as soon as possible while pinning to LTS the released language version.
* While both branches `nixos-unstable` & `nixpkgs-unstable` track `master`. `nixpkgs-unstable` is selected to ensure no additional NixOS dependencies are accidentally introduced into containers over time.

## Open Containers Specification

Labels are respected, for those unfamiliar all built containers _should_ have these [annotations](https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys) applied. Containizen populates with information relevant to its generated base image only. Annotations should be overwritten when extending / using.

## Data Volumes

- Good practice is to ensure a common group for data mounts to share between containers & machines.
- Containizen is optimized for GID=328 or _dat_
- Containizen runs all applications by default as UID=289 or _ctz_
- Default volume is `/data` (following the widely used _common_ container data mount point)

## Vulnerabilities

[Vulnix](https://github.com/flyingcircusio/vulnix) is used for scanning. Checks against NIST, although others databases can also be used. A current vulnerability list is maintained against each assembled container. For security reasons the list is *not* embedded within the assembled container. Vulnerabilities are uploaded as artifacts against the relevant [GitHub Action build](https://github.com/foggyubiquity/containizen/actions). The whitelist excludes items required for building the container that are verified as *not* included in the final result.

**NOTE**: `BASH` may occasionally be listed as a vulnerability, *NIX* requires `BASH` to operate `stdenv` as such it is pushed into all containers. *However* `BASH` is **not** executable from within the container as it is not *symlinked* & installed in a rotating transitory location. As such `BASH` is typically considered a *false-positive*.

## Gotchas

- Read-Only File-System compatible. `/tmp` & `/var` are both volumes & expect `tmpfs` File-Systems to be mounted. While its possible to run this without Read-Only set, bear in mind both `/tmp` & `/var` are ephemeral. These should be mounted at runtime via `TMPFS` (Docker) or `emptyDir` (in Kubernetes)
- `/bin/sh` or `/bin/bash` are not available by default. *sh* is not cross-architecture compatible & introduces security issues. To comply with Cloud Native _(executable containers for any architecture)_ `execlineb` as part of `Skarnet S6` is used. For more information on `sh` issues & challenges see [Skarnet's Post](https://skarnet.org/software/execline/dieshdiedie.html). For more information about using `execlineb` easily see [Just Containers Explainer](https://github.com/just-containers/s6-overlay#executing-initialization-andor-finalization-tasks) or [Danny Spinellas's Getting Started](https://danyspin97.org/blog/getting-started-with-execline-scripting/)
- `root` is required for S6, but privileges are [irreversibly dropped](https://jdebp.eu/FGA/dont-abuse-su-for-dropping-privileges.html) for application execution. A default user `containizen` of uid:289, gid:328 is available. Additional users & groups can be added via the standard `useradd` & `groupadd` commands
- Linux Core Utilities are *not* present, S6 equivalents are, in most cases adding `s6-` will trigger the similar command
- OpenJDK has a bug where GID is reported as `308` instead of `328` when fixed upstream GID for Java check will be re-enabled.

## Local Execution

`foggyubiquity/containizen:act` can be used as a drop-in replacement for *act*s standard runner when wanting Nix capabilities.

* `act -P ubuntu-latest=foggyubiquity/containizen:act -r`
* Cachix works with this image as well if the secret is passed into *act* appropriately


## Further Work (PR Welcome)

- musl support: already available in Nix [Cross Compiling](https://matthewbauer.us/blog/beginners-guide-to-cross.html)
- Cache nix/store in GitHub Actions
- Safe / Functional way of removing `pip` from Python image.
- Goss automatic execution if `goss.yaml` present via S6
- Goss Build Validation
- Other Languages
- Strip Locale's from built container for non-used languages (~15Mb space reduction)
- *Python3xMinimal* is not available currently in NixPkgs, the default *Python3Minimal* binds to Python 3.7. A pull request could be raised to enable more flexible minimal installs (and save compiling Python within this project)
- *Python* pip & language are isolated in *-pip images - multi-link and share
- *Python* pip container is buggy on GitHub actions, but compiles locally & via act - need to identify the delta for this development container
- *Python* (optional) venv support - slower than *shiv*
- *NodeJS* Binary executable detection
