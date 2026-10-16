{nichts, ...}: let
  inherit (nichts.lib) fs;
in {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    defaultSopsFile = fs.host "shika" "host_shika.yaml";

    secrets = {
      "user_passwords/marvin".neededForUsers = true;
    };
  };
}
