{
  lib,
  nichts,
  ...
}: {
  nichts.modules.nixos.install-iso = {
    imports = with nichts.modules.nixos; [
      openssh
    ];

    # Add installer SSH key here for remote installation
    users.users = (
      ["nixos" "root"]
      |> map (user: {
        ${user}.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC0E8i2V+codnEJQxDh5UveAYJR5Mc4690ujXIiKnYh"
        ];
      })
      |> lib.mkMerge
    );
  };
}
