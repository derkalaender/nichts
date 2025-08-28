{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.nichts.desktop;
in {
  config = mkIf (cfg.enable && cfg.flavor == "gnome") {
    # Disable X11, but enable GDM & Mutter, which support Wayland
    services.xserver = {
      enable = true;
      # Enable GNOME
      displayManager.gdm = {
        enable = true;
        wayland = true;
      };
      desktopManager.gnome.enable = true;
    };

    # XWayland
    programs.xwayland.enable = true;

    environment.systemPackages = with pkgs.gnomeExtensions; [
      # System tray
      appindicator
      # Tweaks
      just-perfection
      # Better dock
      dash-to-dock
      # Clipboard manager
      pano
      # Pretty blur
      blur-my-shell
      # Bluetooth battery
      bluetooth-quick-connect
    ];

    # Exclude unused gnome packages
    environment.gnome.excludePackages = with pkgs; [
      orca
      evince
      geary
      epiphany
      gnome-text-editor
      gnome-calendar
      gnome-characters
      gnome-console
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-weather
      gnome-logs
      simple-scan
      totem
      decibels
    ];

    # Required for system tray
    services.udev.packages = with pkgs; [
      gnome-settings-daemon
    ];

    # SSH Agent
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    programs.ssh.startAgent = true;
  };
}
