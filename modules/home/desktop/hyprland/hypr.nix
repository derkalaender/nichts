{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (config.wayland.windowManager.hyprland.enable) {
    wayland.windowManager.hyprland = {
      systemd.enable = false; # Conflicts with USWM
    };
  };
}
