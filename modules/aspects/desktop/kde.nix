{
  nichts.aspects.desktop.nixos = {
    # See https://wiki.nixos.org/wiki/KDE#Plasma_6

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    programs.xwayland.enable = true; # XServer compat
  };

  nichts.aspects.desktop.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # Fix blank taskbar icons
    # See: https://github.com/NixOS/nixpkgs/issues/308252
    home.activation.fixPlasmaIcons = lib.hm.dag.entryAfter ["writeBoundary"] ''
      plasmaConfig="${config.xdg.configHome}/plasma-org.kde.plasma.desktop-appletsrc"
      if [ -f "$plasmaConfig" ]; then
        ${lib.getExe pkgs.gnused} -i \
          's|file:///nix/store/[^/]*/share/applications/|applications:|gi' \
          "$plasmaConfig"
      fi
    '';
  };
}
