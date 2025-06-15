{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.nichts.desktop;
in {
  config = mkIf (cfg.enable && cfg.flavor == "hyprland") {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true; # Support for old X11 applications
      withUWSM = true; # Session manager
    };

    environment.systemPackages = with pkgs; [
      kitty # just for now, as it's the default terminal in Hyprland
    ];

    # Internet
    networking.networkmanager.enable = true;

    # SDDM as the display manager
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };

    # Secrets management
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;
    # automatically unlocks keyring on login
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;
  };
}
