{
  nichts.aspects.desktop.nixos = {pkgs, ...}: {
    # Allow Chromium and Electron to use Wayland natively instead of XWayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

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

    # Use zswap swap caching. Compresses to RAM first before writing to disk
    boot.zswap.enable = true;

    boot.kernel.sysctl = {
      # The default is 60.
      # With zswap, we have a compressing cache layer in-between, so it makes sense for the kernel to use swap more aggressively
      # instead of writing back files.
      "vm.swappiness" = 90;
    };

    # Disable hibernate (not supported with no real swap)
    systemd.sleep.settings.Sleep.AllowHibernation = false;

    # Font management
    # https://wiki.nixos.org/wiki/Fonts
    fonts = {
      fontDir = {
        enable = true;
        decompressFonts = true;
      };
      fontconfig.enable = true;
      fontconfig.useEmbeddedBitmaps = false;
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
          newcomputermodern

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
          victor-mono
          zed-mono
          lilex
        ]);
    };
  };
}
