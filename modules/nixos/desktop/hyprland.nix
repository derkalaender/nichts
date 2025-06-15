{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.nichts.desktop;
in {
  config = mkIf (cfg.enable && cfg.flavor == "hyprland") {
    # TODO
  };
}
