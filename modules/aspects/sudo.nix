{
  nichts.aspects.core.nixos = {
    # TODO: replace with run0
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
