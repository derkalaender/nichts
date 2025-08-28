{lib, ...}: let
  inherit (lib.nichts) fs;
in {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    age.generateKey = true;
    defaultSopsFile = "${fs.secrets}/host_kawauso.yaml";

    secrets = {
      "user_passwords/dot".neededForUsers = true;
    };
  };
}
