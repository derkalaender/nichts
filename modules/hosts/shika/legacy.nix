{
  flake.modules.nixos.host_shika = {
    lib,
    pkgs,
    ...
  }:
    with lib.nichts; {
      nichts.shell.fish = enabled;

      # Enable non-free firmware
      hardware.enableRedistributableFirmware = true;

      # Disable CUPS because of security vuln. ja brauch ich doch
      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        gutenprint
        epson-escpr
        epson-escpr2
      ];
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };

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
    };
}
