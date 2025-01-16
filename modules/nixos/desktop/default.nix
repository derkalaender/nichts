{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with nichts; let
  cfg = config.nichts.desktop;
in {
  options.nichts.desktop = mkEnableOpt "Default desktop configuration";

  config = mkIf cfg.enable {
    # Sound
    # sound = enabled;
    hardware.pulseaudio = disabled;
    security.rtkit = enabled;
    services.pipewire =
      enabled
      // {
        alsa = enabled // {support32Bit = true;};
        pulse = enabled;
      };

    # Disable X11, but enable GDM & Mutter, which support Wayland
    services.xserver =
      disabled
      // {
        # Enable GNOME
        displayManager.gdm =
          enabled
          // {
            wayland = true;
          };
        desktopManager.gnome = enabled;
      };

    # XWayland
    programs.xwayland = enabled;
    # Allow Chromium to be run without XWayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Copy and paste
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];

    # SSH Agent
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    programs.ssh.startAgent = true;

    # Activate special dns config
    nichts.networking.dns = enabled;

    # Use zram as swap -> more responsive
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };

    # Disable hibernate (not supported with no real swap)
    systemd.targets = let
      sleepTarget = state: {
        enable = false;
        unitConfig.DefaultDependencies = false;
      };
    in {
      hibernate = sleepTarget "hibernate";
      hybrid-sleep = sleepTarget "hybrid-sleep";
      suspend-then-hibernate = sleepTarget "suspend-then-hibernate";
    };
  };
}
