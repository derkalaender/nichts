{
  lib,
  pkgs,
  config,
  ...
}:
with lib.nichts; {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./sops.nix
  ];

  nichts.desktop = enabled;

  # Boot options
  boot = {
    # Kernel modules
    kernelModules = [
      "nvidia" # Enable nvidia driver
    ];

    # Load Intel integrated graphics at stage 1 (https://github.com/NixOS/nixos-hardware/blob/master/common/gpu/intel/default.nix)
    initrd.kernelModules = [
      "i915"
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
    # Enable hardware acceleration
    graphics =
      enabled
      // {
        # Intel
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
        ];

        # 32-bit support (e.g. for Wine)
        enable32Bit = true;
        extraPackages32 = with pkgs; [
          driversi686Linux.intel-media-driver
        ];
      };

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

  # Make Wayland use the NVIDIA driver
  services.xserver.videoDrivers = ["nvidia"];

  # Disable CUPS because of security vuln.
  services.printing.enable = false;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  system.stateVersion = "23.11";
}
