{
  lib,
  osConfig,
  ...
}: let
  inherit (lib) mkIf;
  cfg = osConfig.nichts.desktop;
in {
  imports = [
    ./hypr.nix
    ./mako.nix
    ./rofi.nix
    ./apps.nix
  ];

  config = mkIf (cfg.enable && cfg.flavor == "hyprland") {
    wayland.windowManager.hyprland.enable = true; # This enables Hyprland and allows us to query its status in the other module files
  };
}
