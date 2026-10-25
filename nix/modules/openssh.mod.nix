{
  nichts.modules.openssh.nixos = {
    services.openssh = {
      enable = true;
      startWhenNeeded = true; # Socket-based activation
      authorizedKeysInHomedir = false; # Manage solely through NixOS configuration
      settings = {
        PermitRootLogin = "no"; # Disallow root login completely
        # Require public key authentication
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        ChallengeResponseAuthentication = false;
        PermitEmptyPasswords = false;
        PubkeyAuthentication = true;
        LogLevel = "VERBOSE"; # See failed login attempts in details
        LoginGraceTime = "30s";
        MaxSessions = 5;
        UseDns = false;
      };
    };
  };
}
