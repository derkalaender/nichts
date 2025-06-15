{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf isDerivation;
  cfg = config.nichts.desktop;
in {
  imports = [
    ./audio.nix
    ./gnome.nix
    ./hyprland.nix
  ];

  options.nichts.desktop = {
    enable = mkEnableOption "Default desktop configuration";
    flavor = mkOption {
      type = types.enum ["gnome" "hyprland"];
      default = "gnome";
      description = ''
        The desktop environment to use.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Allow Chromium to be run without XWayland
    # BUG: This is experimental and breaks many Electron apps. Instead, we just enable Wayland specifically for Chrome.
    # environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      # Copy and paste
      wl-clipboard
    ];

    # Bluetooth show battery
    hardware.bluetooth.settings = {
      General = {
        Experimental = true;
      };
    };

    # Activate special dns config
    # nichts.networking.dns.enable = true;

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
