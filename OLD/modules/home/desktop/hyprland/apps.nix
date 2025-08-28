{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (config.wayland.windowManager.hyprland.enable) {
    services.hyprpolkitagent.enable = true;

    home.packages = with pkgs; [
      nautilus # file manager
      zenity # dialog boxes
      eog # image viewer
    ];
  };
}
