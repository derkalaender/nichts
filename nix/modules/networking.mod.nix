{
  nichts.modules.networking.nixos = {
    networking = {
      # By default, block all incoming connections
      firewall.enable = true;
      # nftables.enable = true; # This breaks a lot of virtualization features, so we stick to iptables for now

      # Use NetworkManager everywhere (yes, also on servers)
      networkmanager.enable = true;
      dhcpcd.enable = false; # conflicts with NetworkManager's internal DHCP client

      # NetworkManager pulls in ModemManager by default (mkDefault true) for WWAN
      # support. There is no cellular modem in any of these machines (mmcli -L:
      # "No modems were found"), so it only probes every network interface --
      # notably stalling ~2s per resume on the broken wlp9s0.
      modemmanager.enable = false;
    };

    # Use systemd-resolved
    services.resolved.enable = true;

    # Disable NetworkManager-wait-online, as it can cause boot delays
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
