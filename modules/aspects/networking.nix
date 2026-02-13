{
  nichts.aspects.core.nixos = {pkgs, ...}: {
    networking = {
      # By default, block all incoming connections
      firewall.enable = true;
      # nftables.enable = true; # This breaks a lot of virtualization features, so we stick to iptables for now

      # Use NetworkManager everywhere (yes, also on servers)
      networkmanager.enable = true;
      dhcpcd.enable = false; # conflicts with NetworkManager's internal DHCP client

      # Make resolvconf forward DNS requests to dnscrypt-proxy
      resolvconf.useLocalResolver = true;
    };

    # Disable NetworkManager-wait-online, as it can cause boot delays
    systemd.services.NetworkManager-wait-online.enable = false;

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

        # Make the tailscale domain resolve to the Tailscale MagicDNS resolver
        # TODO: This is such a hack!!! Tailscale DNS should just work...
        # See https://github.com/tailscale/tailscale/issues/4254
        forwarding_rules =
          builtins.concatStringsSep "\n" [
            "tail4cf748.ts.net 100.100.100.100"
          ]
          |> pkgs.writeText "forwarding-rules.txt";
      };
    };
  };
}
