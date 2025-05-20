{pkgs, ...}: {
  imports = [
    ./users.nix
    ./sops.nix
    ./facter.nix
    ./disko.nix
  ];

  boot = {
    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Non-free firmware
  hardware.enableRedistributableFirmware = true;

  # Enable SSH server
  services.openssh = {
    enable = true;
    allowSFTP = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  system.stateVersion = "24.11";
}
