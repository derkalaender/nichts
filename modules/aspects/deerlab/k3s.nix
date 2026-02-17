{
  # See https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md

  nichts.aspects.deerlab._.k3s = {
    nixos = {
      services.k3s = {
        enable = true;
        gracefulNodeShutdown.enable = true;
        disable = [
          "traefik" # customized version
          "local-storage" # customized version
          "metrics-server" # buggy? prevents namespaces from being deleted sometimes
          "servicelb" # we use metallb
        ];
      };

      # https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-nodes
      networking.firewall.allowedTCPPorts = [6443];
      networking.firewall.allowedUDPPorts = [8472];
    };

    _.server.nixos = {
      services.k3s = {
        role = "server";
        extraFlags = [
          "--cluster-cidr 10.69.0.0/16,fd69:693b:00d9:100::/56"
          "--service-cidr 10.70.0.0/16,fd69:693b:00d9:200::/112"
          "--flannel-ipv6-masq"
        ];
      };
    };
  };
}
