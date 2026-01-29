{
  self,
  nichts,
  ...
}: let
  inherit (nichts.lib) fs;
in {
  nichts.aspects.hosts._.shika.nixos = {
    sops = {
      age.keyFile = "/root/.config/sops/age/keys.txt";
      defaultSopsFile = fs.secret "host_shika.yaml";

      secrets = {
        "user_passwords/marvin".neededForUsers = true;
      };
    };
  };
}
