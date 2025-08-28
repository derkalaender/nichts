{
  lib,
  config,
  ...
}: let
  inherit (lib.nichts) fs;
in {
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = "${fs.secrets}/user_marvin.yaml";

    secrets = {
      ssh_private.path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      ssh_public.path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
  };
}
