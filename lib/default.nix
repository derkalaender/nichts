{
  self,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  nichts = {
    mkEnableOpt = name: {enable = mkEnableOption name;};

    enabled = {
      enable = true;
    };

    disabled = {
      enable = false;
    };

    fs = rec {
      secrets = get-file "secrets";
      get-file = path: "${self}/${path}";
    };
  };
}
