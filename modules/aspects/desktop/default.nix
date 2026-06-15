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

    # Use zram as swap -> more responsive
    # Used by Fedora, Bazzite and CachyOS
    # CachyOS sets to 100% by default (https://github.com/CachyOS/CachyOS-Settings/blob/9c623471493d8faa22614ee5eecbd59a6d028b53/usr/lib/systemd/zram-generator.conf)
    zramSwap = {
      enable = true;
      memoryPercent = 100;
    };
    boot.kernel.sysctl = {
      # With zram, we want to "swap" into it, so more gets compressed
      # Taken from CachyOS (https://github.com/CachyOS/CachyOS-Settings/blob/9c623471493d8faa22614ee5eecbd59a6d028b53/usr/lib/udev/rules.d/30-zram.rules)
      "vm.swappiness" = 150;
      # With zram, reading from swap is basically free. Reading several swap pages at once is therefore just overhead.
      # Taken from CachyOS (https://github.com/CachyOS/CachyOS-Settings/blob/9c623471493d8faa22614ee5eecbd59a6d028b53/usr/lib/sysctl.d/70-cachyos-settings.conf#L18)
      "vm.page-cluster" = 0;
    };

    # Disable hibernate (not supported with no real swap)
    systemd.sleep.settings.Sleep.AllowHibernation = false;

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
        ]);
    };
  };
}
