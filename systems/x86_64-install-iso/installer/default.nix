{...}: {
  config = {
    nichts.shell.fish.enable = true;

    services.openssh.enable = true;

    users.users =
      ["nixos" "root"]
      |> builtins.map (user: {
        name = user;
        value = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTyrsqSn9oAlqyThh1VoIqLoOzNV5a9IAeERC09fAFU"
          ];
        };
      })
      |> builtins.listToAttrs;
  };
}
