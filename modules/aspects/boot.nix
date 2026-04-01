{
  nichts.aspects.core.nixos = {
    # Use limine by default
    boot.loader = {
      efi.canTouchEfiVariables = true;

      limine = {
        enable = true;
        efiSupport = true;
        enableEditor = false; # Otherwise, can easily get root
        validateChecksums = true; # Verify integrity
        panicOnChecksumMismatch = true;
        maxGenerations = 10; # For GC
      };
    };
  };

  nichts.aspects.secureboot.nixos = {
    # TODO
  };

  nichts.aspects.desktop.nixos = {pkgs, ...}: {
    boot = {
      # Use Zen Kernel for better responsiveness
      kernelPackages = pkgs.linuxPackages_zen;

      # Reduced wait time
      loader.timeout = 1;

      # Graphical boot
      plymouth = {
        enable = true;
        theme = "colorful_sliced";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = ["colorful_sliced"];
          })
        ];
      };
      loader.limine.extraConfig = ''
        quiet: yes
      '';

      # Less log output
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
