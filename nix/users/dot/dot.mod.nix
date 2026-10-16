{nichts, ...}: let
  inherit (nichts.lib) fs;
in {
  nichts.entities.users.dot.module.nixos = {config, ...}: {
    # User passwords
    sops.secrets."user_passwords/dot" = {
      sopsFile = fs.user "dot" "deerlab.yaml";
      neededForUsers = true;
    };

    # User definitions
    users.users = {
      dot = {
        description = "Dot the Deer";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets."user_passwords/dot".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGz0wxyVRtEAFeWUdjIH1c4Se3JJNr2qgpeKevJtePKs" # Deerlab
        ];
        extraGroups = ["wheel" "networkmanager"];
      };
    };
  };

  nichts.entities.users.dot.module.home = {};
}
