{ language
, withNPM ? "false"
, pkgs
}:

let
  common = import ../config.nix {
    inherit pkgs;
  };

in
common // {
  ExposedPorts = common.ExposedPorts // {
    # "<port>/<tcp|udp>": {}
    "3000/tcp" = {};
  };
  Env = common.Env ++ [
    "NODE_PATH=/node_modules"
    "NODE_ENV=production"
  ] ++ (
    if withNPM == "true"
    then [ "S6_CMD_ARG0=\"\"" ]
    else []
  );
  # Cmd must be specified as Nix strips any prior definition out to ensure clean execution
  Cmd = if withNPM == "true"
  then [
    # Full NodeJS version also contains NPM, strictly not necessary for production deployments
    "${language.pkg}/bin/npm"
    "start"
  ]
  else [];
  Labels = common.Labels // {
    # Custom Labels
    "from" = "containizen";
  };
}
