{
  nichts,
  lib,
  ...
}: {
  nichts.aspects.deerlab = {
    includes = with nichts.aspects; [
      openssh
    ];

    nixos = {
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkj75RIzUSmFX33FFYAc8Ek6V0HpeTqrZel6T4GL8XL" # deploy-rs
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGz0wxyVRtEAFeWUdjIH1c4Se3JJNr2qgpeKevJtePKs" # Deerlab
      ];

      # nixos-anywhere works by uploading its own public key to the target system
      services.openssh.authorizedKeysInHomedir = lib.mkForce true;
    };
  };
}
