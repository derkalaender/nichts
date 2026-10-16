{
  config,
  nichts,
  ...
}:
{
  imports = [
    ./disko.nix
    ./deploy.nix
  ];

  nichts.entities.hosts.kawauso = {
    users = [
      "dot"
      "kyson"
    ];

    module.nixos = {
      imports = [
        ./sops.nix
      ]
      ++ (with nichts.lib.units.nixos; [
        deerlab
        deerlab-k3s
        deerlab-k3s-server
        minecraft
      ]);

      # Disk configuration via disko
      inherit (config.flake.diskoConfigurations.kawauso) disko;

      # Additional hardware config via facter
      hardware.facter.reportPath = ./facter.json;

      # Minecraft, Traefik
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      # Tailscale subnet routing
      services.tailscale = {
        useRoutingFeatures = "server";
        extraSetFlags = [
          "--advertise-routes=192.168.169.0/24,fd69:693b:d9::/64" # LAN subnets
        ];
      };

      # Forwarding and still accept Router Advertisements for IPv6
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "net.ipv6.conf.all.accept_ra_rt_info_max_plen" = 64;
        "net.ipv6.conf.all.accept_ra" = 2;
      };

      system.stateVersion = "25.11";
    };
  };
}
