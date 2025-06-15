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
      adwaita-icon-theme # For GNOME apps
      xdg-user-dirs # Well known directories
      xdg-user-dirs-gtk # Well known directories
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

    services.gvfs.enable = true; # For trash to work
    services.udisks2.enable = true; # Disk querying
    services.devmon.enable = true; # Automatic USB mounting
    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
    services.accounts-daemon.enable = true;
    services.gnome.sushi.enable = true; # Quick Previewer for Nautilus
    services.libinput.enable = true;
    services.avahi.enable = true; # TODO: consider moving to networking module
    programs.dconf.enable = true; # for GTK apps config

    # Icon fixes
    xdg.mime.enable = true;
    xdg.icons.enable = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk]; # makes GTK apps happy
    };
  };
}
