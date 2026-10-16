{ ... }: {
  nichts.entities.users.dot.description = "Dot the Deer";
  nichts.entities.users.dot.extraGroups = [
    "wheel"
    "networkmanager"
  ];
  nichts.entities.users.dot.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGz0wxyVRtEAFeWUdjIH1c4Se3JJNr2qgpeKevJtePKs" # Deerlab
  ];

  nichts.entities.users.dot.module.nixos = {
    sops.secrets."user_passwords/dot" = {
      sopsFile = ./secrets/deerlab.yaml;
      neededForUsers = true;
    };
  };
}
