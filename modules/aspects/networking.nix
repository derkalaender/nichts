{
  nichts.aspects.core.nixos = {
    networking = {
      # By default, block all incoming connections
      firewall.enable = true;
      # nftables.enable = true; # This breaks a lot of virtualization features, so we stick to iptables for now

      # Use NetworkManager everywhere (yes, also on servers)
      networkmanager.enable = true;
      dhcpcd.enable = false; # conflicts with NetworkManager's internal DHCP client
    };

    # Use systemd-resolved
    services.resolved.enable = true;

    # Disable NetworkManager-wait-online, as it can cause boot delays
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
