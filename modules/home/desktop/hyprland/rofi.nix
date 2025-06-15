{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (config.wayland.windowManager.hyprland.enable) {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.ghostty}/bin/ghostty";
    };
  };
}
