{...}: {
  config = {
    # See more here: https://github.com/cynicsketch/nix-mineral/blob/main/nix-mineral.nix

    # Default firewall blocks all incoming connections (unless a service opens a port)
    networking.firewall.enable = true;

    # Configure sudo
    # We use memory-safe sudo-rs Rust implementation
    security.sudo.enable = false; # Disable default sudo
    security.sudo-rs = {
      enable = true;
      execWheelOnly = true; # Prevent potential CVEs by making only wheel users able to use sudo
      # Show asterisks when typing password
      extraConfig = ''
        Defaults pwfeedback
      '';
    };
  };
}
