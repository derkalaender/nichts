{
  flake.modules.nixos.core = {host, ...}: {
    networking = {
      hostName = host;

      # By default, block all incoming connections
      firewall.enable = true;
      nftables.enable = true;
    };
  };

  flake.modules.nixos.desktop = {
    networking = {
      networkmanager.enable = true;
      dhcpcd.enable = false; # conflicts with NetworkManager's internal DHCP client

      # TODO add admin users to networkmanager group here

      # Make resolvconf forward DNS requests to dnscrypt-proxy
      resolvconf.useLocalResolver = true;
    };

    # See https://wiki.nixos.org/wiki/Encrypted_DNS
    # This sets up DNS over HTTPS (DoH)
    # As a nice bonus, we also get DNS caching
    services.dnscrypt-proxy = {
      enable = true;
      # Reference: https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
      settings = {
        ipv6_servers = true; # We also want IPv6 support
        require_dnssec = true;
        http3 = true;
      };
    };
  };
}
