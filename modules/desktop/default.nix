{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types mkMerge mkIf;
  cfg = config.nichts.desktop;
in {
  options.nichts.desktop = {
    flavor = mkOption {
      type = types.enum ["gnome" "hyprland"];
      default = "gnome";
      description = ''
        The desktop environment to use.
      '';
    };
  };

  config = mkMerge [
    (mkIf (cfg.flavor == "gnome") {
      flake.modules.nixos.desktop.imports = [config.flake.modules.nixos.desktop_gnome];
      flake.modules.homeManager.desktop = {}; # Needed so there's always a homeManager.desktop
    })
    (mkIf (cfg.flavor == "hyprland") {
      flake.modules.nixos.desktop.imports = [config.flake.modules.nixos.desktop_hyprland];
      flake.modules.homeManager.desktop.imports = [config.flake.modules.homeManager.desktop_hyprland];
    })

    {
      flake.modules.nixos.desktop = {pkgs, ...}: {
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
              noto-fonts-lgc-plus
              noto-fonts-color-emoji
              liberation_ttf
              dejavu_fonts
              ubuntu-sans
              roboto
              inter
              open-sans
              lato
              corefonts

              # Icons
              material-icons
              font-awesome
            ]
            # See https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
            ++ (with pkgs.nerd-fonts; [
              dejavu-sans-mono
              fira-code
              fira-mono
              geist-mono
              hack
              jetbrains-mono
              mononoki
              noto
            ]);
        };
      };
    }
  ];
}
