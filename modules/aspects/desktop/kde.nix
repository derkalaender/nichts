{
  nichts.aspects.desktop.nixos = {
    # See https://wiki.nixos.org/wiki/KDE#Plasma_6

    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    programs.xwayland.enable = true; # XServer compat

    # KWin 6.7.5 + RDNA4 (RX 9070 XT, Navi 48) bug: KWin programs the hardware
    # cursor plane with DRM_FORMAT_RGBA8888 ("RA24"), which amdgpu advertises as
    # supported for this generation but the display hardware rejects. Every
    # atomic modeset commit then fails with EINVAL, no page flip happens, and the
    # screen freezes until an input event forces a new commit attempt (hence
    # "wiggling the mouse unfreezes it"). Forcing a software-composited cursor
    # avoids the broken plane entirely.
    # See: https://bugs.kde.org/show_bug.cgi?id=524731
    #      https://gitlab.freedesktop.org/drm/amd/-/work_items/5339
    #      https://github.com/CachyOS/distribution/issues/547
    #
    # One setting covers both the Plasma session and SDDM's Wayland greeter:
    # environment.sessionVariables lands in /etc/pam/environment, and both
    # sessions read it via pam_env (/etc/pam.d/sddm -> include login).
    #
    # Do NOT also set services.displayManager.sddm.settings.General.GreeterEnvironment:
    # SDDM 0.21 takes everything after the first "=" as that variable's value, so
    # appending a second variable corrupts QT_WAYLAND_SHELL_INTEGRATION and the
    # greeter aborts (SIGABRT) with a black screen.
    environment.sessionVariables.KWIN_FORCE_SW_CURSOR = "1";
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
