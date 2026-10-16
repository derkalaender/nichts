{ ... }: {
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";

    secrets = {
      "user_passwords/marvin" = {
        sopsFile = ./secrets/user_passwords.yaml;
        neededForUsers = true;
      };
    };
  };
}
