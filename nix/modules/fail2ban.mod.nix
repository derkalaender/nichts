{
  nichts.modules.nixos.fail2ban = {
    services.fail2ban = {
      enable = true;
      maxretry = 3; # Ban IP after 3 failures
      ignoreIP = [
        # Whitelist internal network
        "192.168.0.0/16" # ipv4 private
        "fd00::/8" # ipv6 private
      ];
      bantime = "2h";
      bantime-increment = {
        # Increases ban time for repeated offenses
        enable = true;
        overalljails = true; # Calculate based on all jails
      };
    };
  };
}
