{
  nichts.entities.users.kyson.module.nixos = {
    users.users = {
      kyson = {
        description = "Kyson";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItTurzE0yXGvSH38e6/iMkSGMAPw3lvNl63jjSO6H2H"
        ];
      };
    };
  };

  nichts.entities.users.kyson.module.home = { };
}
