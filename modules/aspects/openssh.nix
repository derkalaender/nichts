{
  nichts.aspects.openssh.nixos = {
    services.openssh = {
      enable = true;
      startWhenNeeded = true; # Socket-based activation
      authorizedKeysInHomedir = false; # Manage solely through NixOS configuration
      settings = {
        PermitRootLogin = "prohibit-password"; # Disable root login with password
        # Require public key authentication
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PubkeyAuthentication = true;
      };
    };
  };
}
