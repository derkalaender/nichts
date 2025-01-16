{
  lib,
  pkgs,
  config,
  ...
}:
with lib.nichts; {
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./users.nix
    ./sops.nix
    ./disko.nix
  ];

  nichts.desktop = enabled;

  # Boot options
  boot = {
    # Use latest kernel. 6.12.5 as of now.
    kernelPackages = pkgs.linuxPackages_latest;

    # Bootloader, we forcefully deactivate systemd-boot for Lanzaboote
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = true;

    # Enable Lanzaboote
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    # Enable Plymouth Boot Screen
    plymouth = {
      enable = true;
      theme = "catppuccin-mocha";
      themePackages = with pkgs; [
        (catppuccin-plymouth.override {
          variant = "mocha";
        })
      ];
    };
  };

  # Enable non-free firmware
  hardware.enableRedistributableFirmware = true;

  # Disable CUPS because of security vuln.
  services.printing.enable = false;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  system.stateVersion = "23.11";
}
