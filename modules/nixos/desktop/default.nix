{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf isDerivation;
  cfg = config.nichts.desktop;
in {
  options.nichts.desktop.enable = mkEnableOption "Default desktop configuration";

  config = mkIf cfg.enable {
    # Sound
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };

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
    # Allow Chromium to be run without XWayland
    # environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages =
      (with pkgs; [
        # Copy and paste
        wl-clipboard
      ])
      ++ (with pkgs.gnomeExtensions; [
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
      ]);

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

    # Bluetooth show battery
    hardware.bluetooth.settings = {
      General = {
        Experimental = true;
      };
    };

    # SSH Agent
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    programs.ssh.startAgent = true;

    # Activate special dns config
    nichts.networking.dns.enable = true;

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

    # Font management
    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs;
        [
          noto-fonts
          noto-fonts-cjk-sans # Chinese, Japanese, Korean
          noto-fonts-color-emoji

          # Icons
          material-icons
          font-awesome
        ]
        # Getting all of them. Includes Jetbrains Mono, Fira Code, Meslo, etc.
        # See https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
        ++ (pkgs.nerd-fonts
          |> builtins.attrValues
          |> builtins.filter isDerivation);
    };
  };
}
