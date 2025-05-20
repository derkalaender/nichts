{...}: {
  config = {
    # See more here: https://github.com/cynicsketch/nix-mineral/blob/main/nix-mineral.nix

    # Default firewall blocks all incoming connections (unless a service opens a port)
    networking.firewall.enable = true;

    # Configure sudo
    # FIXME Ideally, we'd use sudo-rs, but currently no other module really supports it (the options don't transfer implicitly)
    security.sudo = {
      execWheelOnly = true; # Prevent potential CVEs by making only wheel users able to use sudo
      # Show asterisks when typing password, no intro text
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
      '';
    };
  };
}
