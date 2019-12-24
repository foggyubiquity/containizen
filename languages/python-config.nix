{ language
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
  };
  Env = common.Env ++ [];
  # Cmd must be specified as Nix strips any prior definition out to ensure clean execution
  Cmd = [];
  Labels = common.Labels // {
    # Custom Labels
    "from" = "containizen";
  };
}
