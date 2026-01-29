{
  nichts.aspects.desktop.nixos = {
    # See https://wiki.nixos.org/wiki/KDE#Plasma_6

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    programs.xwayland.enable = true; # XServer compat
  };
}
