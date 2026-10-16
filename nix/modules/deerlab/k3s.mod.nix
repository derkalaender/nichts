{
  # See https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/cluster/k3s/docs/USAGE.md

  nichts.modules.nixos.deerlab-k3s = {config, ...}: {
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

    # Required by longhorn
    # https://github.com/longhorn/longhorn/issues/2166#issuecomment-2994323945
    services.openiscsi = {
      enable = true;
      name = "${config.networking.hostName}-initiator";
    };
    systemd.services.iscsid.serviceConfig = {
      PrivateMounts = "yes";
      BindPaths = "/run/current-system/sw/bin:/bin";
    };
  };

  nichts.modules.nixos.deerlab-k3s-server = {
    services.k3s = {
      role = "server";
      extraFlags = [
        "--cluster-cidr 10.69.0.0/16,fd05:14cb:35e1::/56"
        "--service-cidr 10.70.0.0/16,fd05:14cb:35e2::/112"
        "--flannel-ipv6-masq"
      ];
    };
  };
}
