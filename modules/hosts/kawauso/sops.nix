{nichts, ...}: let
  inherit (nichts.lib) fs;
in {
  nichts.aspects.hosts._.kawauso.nixos = {
    sops = {
      age.keyFile = "/root/.config/sops/age/keys.txt";
      defaultSopsFile = fs.secret "host_kawauso.yaml";

      secrets = {
        "user_passwords/dot".neededForUsers = true;
      };
    };
  };
}
