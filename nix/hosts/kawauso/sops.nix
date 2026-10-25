{
  config,
  ...
}:
{
  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";

    secrets = {
      "user_passwords/dot" = {
        sopsFile = ./secrets/user_passwords.yaml;
        neededForUsers = true;
      };
    };
  };

  users.users.dot.hashedPasswordFile = config.sops.secrets."user_passwords/dot".path;
}
