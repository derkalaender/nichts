{lib, ...}: let
  inherit (lib.nichts) fs;
in {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    age.generateKey = true;
    defaultSopsFile = "${fs.secrets}/host_shika.yaml";

    secrets = {
      "user_passwords/marvin".neededForUsers = true;
    };
  };
}
