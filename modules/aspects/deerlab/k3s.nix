{
  # See https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md

  nichts.aspects.deerlab._.k3s = {
    nixos = {
      services.k3s = {
        enable = true;
        gracefulNodeShutdown.enable = true;
        disable = ["traefik"];
      };

      # https://docs.k3s.io/installation/requirements#inbound-rules-for-k3s-nodes
      networking.firewall.allowedTCPPorts = [6443];
      networking.firewall.allowedUDPPorts = [8472];
    };

    _.server.nixos = {
      services.k3s = {
        role = "server";
      };
    };
  };
}
