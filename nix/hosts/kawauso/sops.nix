{nichts, ...}: let
  inherit (nichts.lib) fs;
in {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    defaultSopsFile = fs.host "kawauso" "host_kawauso.yaml";
  };
}
