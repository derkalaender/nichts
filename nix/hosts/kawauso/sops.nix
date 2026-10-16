{ ... }: {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/host_kawauso.yaml;
  };
}
