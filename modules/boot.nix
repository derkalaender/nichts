{
  flake.modules.nixos.core = {
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

  flake.modules.nixos.secureboot = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib.nichts) fs;
  in {
    secureboot.enable = true;

    # Key management
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    # Provision PKI bundle with sops
    sops = {
      secrets = let
        mkSecret = path: {
          format = "binary";
          sopsFile = "${fs.secrets}/secureboot/${path}";
          path = "/var/lib/sbctl";
        };
      in {
        secureboot-guid = mkSecret "GUID";
        secureboot-pk-key = mkSecret "keys/PK/PK.key";
        secureboot-pk-pem = mkSecret "keys/PK/PK.pem";
        secureboot-kek-key = mkSecret "keys/KEK/KEK.key";
        secureboot-kek-pem = mkSecret "keys/KEK/KEK.pem";
        secureboot-db-key = mkSecret "keys/db/db.key";
        secureboot-db-pem = mkSecret "keys/db/db.pem";
      };
    };
  };

  flake.modules.nixos.desktop = {pkgs, ...}: {
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

      # Less log output
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
        # "kvm.enable_virt_at_load=0" # Fixes VirtualBox on newer kernels (see https://github.com/NixOS/nixpkgs/issues/363887)
      ];
    };
  };
}
