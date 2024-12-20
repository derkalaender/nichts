{lib, pkgs, config, ...}:
with lib.nichts; {
  imports = [
    ./users.nix
    ./sops.nix
  ];

  nichts.desktop = enabled;

  # Boot options
  boot = {
    # Kernel modules
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    kernelModules = [
      "kvm-intel"
      "nvidia" # Enable nvidia driver
    ];

    # Use latest kernel. 6.12.5 as of now.
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader
    loader.systemd-boot = enabled;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware configuration
  hardware = {
    enableRedistributableFirmware = true; # Enable non-free firmware
    graphics = enabled; # Enable graphics drivers

    nvidia = {
      # Required for better compatibility
      modesetting.enable = true;
      # This is unstable
      powerManagement.enable = false;
      # Settings panel
      nvidiaSettings = true;
      # I have a GTX1060 which doesn't support the new open module parts
      open = false;
      # Use latest driver version. 565.77 as of now.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Filesystems
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c1c2f7f0-7f88-4e30-acc8-556ef01dc391";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4B2D-30F9";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/301146be-b026-4efd-95ce-d7e43bd36239"; }
    ];

  # Disable CUPS because of security vuln.
  services.printing.enable = false;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  system.stateVersion = "23.11";
}
