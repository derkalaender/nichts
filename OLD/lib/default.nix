{lib, ...}: let
  inherit (lib) mkEnableOption;
  inherit (lib.snowfall.fs) get-file;
in {
  mkEnableOpt = name: {enable = mkEnableOption name;};

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  fs = {
    secrets = get-file "secrets";
  };
}
