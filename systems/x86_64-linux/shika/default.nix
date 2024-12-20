{lib, pkgs, config, ...}:
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

  # Disable CUPS because of security vuln.
  services.printing.enable = false;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  system.stateVersion = "23.11";
}
