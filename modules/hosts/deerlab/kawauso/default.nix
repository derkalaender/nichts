{
  config,
  nichts,
  ...
}: {
  nichts.aspects.hosts._.kawauso = {
    includes = with nichts.aspects; [
      deerlab
      deerlab._.k3s
      deerlab._.k3s._.server
    ];

    nixos = {
      # Disk configuration via disko
      inherit (config.flake.diskoConfigurations.kawauso) disko;

      # Additional hardware config via facter
      hardware.facter.reportPath = ./facter.json;

      # Set network hostname to host configuration name
      networking.hostName = "kawauso";

      # Minecraft, Traefik
      networking.firewall.allowedTCPPorts = [25565 80 443];
      networking.firewall.allowedUDPPorts = [25565];

      # Tailscale subnet routing
      services.tailscale = {
        useRoutingFeatures = "server";
        extraSetFlags = [
          "--advertise-routes=192.168.169.0/24,fd69:693b:d9::/64" # LAN subnets
        ];
      };

      system.stateVersion = "25.11";
    };
  };
}
