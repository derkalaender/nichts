{
  lib,
  host,
  ...
}:
with lib.nichts; {
  networking = {
    # Each system has a (somewhat) unique name, that can be used as the hostname
    hostName = host;
    usePredictableInterfaceNames = true;

    # Use IPv6
    enableIPv6 = true;

    # Set the nameservers localhost as we're using dnscrypt for DoH/DoT
    nameservers = ["127.0.0.1" "::1"];
    # The following is needed because of dnscrypt (TODO are both required? https://nixos.wiki/wiki/Encrypted_DNS)
    dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.dns = "none";

    # TODO use nftables instead of iptables, but Docker currently only supports iptables https://github.com/moby/moby/issues/26824
  };

  # Enable DoH/DoT
  services.dnscrypt-proxy2 = enabled // {
    settings = {
      ipv4_servers = true;
      ipv6_servers = true;
      server_names = ["cloudflare" "cloudflare-ipv6"];
      cache = true;
    };
  };

  # TODO the DNS config will hopefully soon be superseded by Pi-hole
}
