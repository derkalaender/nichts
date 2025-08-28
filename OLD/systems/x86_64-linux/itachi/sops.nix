{lib, ...}: let
  inherit (lib.nichts) fs;
in {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    defaultSopsFile = "${fs.secrets}/host_itachi.yaml";

    secrets = {
      "user_passwords/marvin".neededForUsers = true;
    };
  };
}
