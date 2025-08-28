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
      ssh_private = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
      ssh_public = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
        mode = "0644";
      };
      ssh_colmena_private = {
        path = "${config.home.homeDirectory}/.ssh/colmena";
        mode = "0600";
      };
      ssh_colmena_public = {
        path = "${config.home.homeDirectory}/.ssh/colmena.pub";
        mode = "0644";
      };
    };
  };
}
