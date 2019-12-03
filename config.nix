{ pkgs, unstable }:

{
  # Hostname = "";
  # Domainname = "";
  User = "root"; # S6 Operates as the Process Supervisor i.e. PID 1. It must be a root process. Permissions are dropped to the system user containizen for running applications
  ExposedPorts = {
    # "<port>/<tcp|udp>": {}
    "3000/tcp" = {};
  };
  Env = [
    # Settings from https://github.com/just-containers/s6-overlay#customizing-s6-behaviour
    "S6_KEEP_ENV=1"
    "S6_BEHAVIOUR_IF_STAGE2_FAILS=2" # Termination by default to ensure container respects cloud native approach of operating as a stand alone executable
    "S6_CMD_ARG0=/start"
    "S6_FIX_ATTRS_HIDDEN=1"
    "S6_READ_ONLY_ROOT=1"
  ];
  # Cmd must be specified as Nix strips any prior definition out to ensure clean execution
  Cmd = "";
  # Healthcheck -- should never be used with containers targeting Kubernetes
  # ArgsEscaped -- Windows Containers only
  Volumes = {
    "/data" = {};
    "/tmp" = {};
    "/var" = {};
  };
  WorkingDir = "/opt/app";
  Entrypoint = "/init";
  Labels = {
    # Annotations from OCI Specification https://github.com/opencontainers/image-spec/blob/master/annotations.md#pre-defined-annotation-keys
    "org.opencontainers.image.authors" = "https://github.com/sotekton/containizen/graphs/contributors"; # Override in DockerFile
    "org.opencontainers.image.created" = pkgs.lib.removeSuffix "\n" (builtins.readFile (pkgs.runCommand "oci-created" {} ''TZ=utc date --rfc-3339="seconds" > $out''));
    "org.opencontainers.image.description" = "Max Security Minimal Footprint Base Containers";
    "org.opencontainers.image.documentation" = "https://hub.docker.com/r/sotekton/containizen";
    "org.opencontainers.image.licenses" = "MPL-2.0";
    "org.opencontainers.image.revision" = pkgs.lib.removeSuffix "\n" (
      if builtins.pathExists .git/refs/heads/master
      then builtins.readFile ./.git/refs/heads/master
      else builtins.getEnv "GITHUB_HEAD_REF"
    );
    "org.opencontainers.image.source" = "https://github.com/sotekton/containizen";
    "org.opencontainers.image.title" = "Containizen";
    "org.opencontainers.image.url" = "https://hub.docker.com/r/sotekton/containizen";
    "org.opencontainers.image.vendor" = "Sotekton";
    "org.opencontainers.image.version" = "master";
  };
}
