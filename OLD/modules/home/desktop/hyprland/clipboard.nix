{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (config.wayland.windowManager.hyprland.enable) {
    services.cliphist = {
      enable = true;
      allowImages = true;
    };
  };
}
