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

  nichts.desktop.enable = true;
  nichts.desktop.flavor = "gnome";
  nichts.shell.fish = enabled;
  nichts.gaming.enable = true;
  nichts.security.secureboot.enable = true;

  # Boot options
  boot = {
    # Use Zen Kernel for better responsiveness
    kernelPackages = pkgs.linuxPackages_zen;

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

    # From https://wiki.nixos.org/wiki/Plymouth#Usage
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "kvm.enable_virt_at_load=0" # Fixes VirtualBox on newer kernels (see https://github.com/NixOS/nixpkgs/issues/363887)
    ];
  };

  # Enable non-free firmware
  hardware.enableRedistributableFirmware = true;

  # Disable CUPS because of security vuln.
  services.printing.enable = false;

  # Enable podman
  virtualisation.podman.enable = true;

  # Virtualbox
  virtualisation.virtualbox.host.enable = true;
  users.users.marvin.extraGroups = ["vboxusers" "wireshark"];

  # Enable flatpak
  services.flatpak.enable = true;

  # Allow running Non-NixOS binaries
  programs.nix-ld = {
    enable = true;
    # Steam contains most necessary libraries. See https://wiki.nixos.org/wiki/FAQ#I've_downloaded_a_binary,_but_I_can't_run_it,_what_can_I_do?
    libraries = pkgs.steam-run.args.multiPkgs pkgs;
  };
  environment.systemPackages = with pkgs; [
    nix-alien
  ];

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Enable JLink
  programs.jlink = {
    enable = true;
    trustedUsers = [
      "marvin"
    ];
  };

  system.stateVersion = "23.11";
}
