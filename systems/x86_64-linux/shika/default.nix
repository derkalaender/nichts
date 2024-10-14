{lib, pkgs, config, ...}:
with lib.nichts; {
  imports = [
    ./users.nix
  ];

  nichts.desktop = enabled;

  # Boot options
  boot = {
    # Kernel modules
    initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
    kernelModules = [
      "kvm-intel"
      "nvidia"
      # TODO intel gpu module
    ];

    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader
    loader.systemd-boot = enabled;
    loader.efi.canTouchEfiVariables = true;
  };

  # Hardware configuration
  hardware = {
    enableRedistributableFirmware = true; # Enable non-free firmware
    opengl = enabled; # TODO not sure if this is necessary
    nvidia = {
      # need newer Nvidia driver because of newer Kernel version
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "560.35.03";
        sha256_64bit = "sha256-8pMskvrdQ8WyNBvkU/xPc/CtcYXCa7ekP73oGuKfH+M=";
        sha256_aarch64 = "sha256-s8ZAVKvRNXpjxRYqM3E5oss5FdqW+tv1qQC2pDjfG+s=";
        openSha256 = "sha256-/32Zf0dKrofTmPZ3Ratw4vDM7B+OgpC4p7s+RHUjCrg=";
        settingsSha256 = "sha256-kQsvDgnxis9ANFmwIwB7HX5MkIAcpEEAHc8IBOLdXvk=";
        persistencedSha256 = "sha256-E2J2wYYyRu7Kc3MMZz/8ZIemcZg68rkzvqEwFAL3fFs=";
      };
      nvidiaSettings = false; # can't have this enabled with the newer driver for some reason?
    };
  };

  # X11 Windowing System
  # TODO replace with Wayland
  services.xserver = enabled // {
    # Enable GNOME
    displayManager.gdm = enabled;
    desktopManager.gnome = enabled;
    # Keyboard layout
    xkb = {
      layout = "de";
      variant = "";
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

  # Configure console keymap
  console.keyMap = "de";

  # Disable CUPS because of security vuln.
  services.printing.enable = false;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  system.stateVersion = "23.11";
}
