{ ... }: {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    defaultSopsFile = ../../../secrets/host_shika.yaml;

    secrets = {
      "user_passwords/marvin".neededForUsers = true;
    };
  };
}
