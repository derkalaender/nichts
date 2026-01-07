{config, ...}: {
  nichts.hosts.shika = {
    system = "x86_64-linux";
  };

  flake.modules.nixos.host_shika = {
    imports = [
      config.flake.modules.nixos.desktop
      config.flake.modules.nixos.gaming
    ];

    networking.firewall.allowedTCPPorts = [25565];
    networking.firewall.allowedUDPPorts = [25565];

    services.hardware.openrgb.enable = true;
  };
}
