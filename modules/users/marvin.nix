{
  nichts.users = {
    marvin = {};
  };

  flake.modules.nixos.user_marvin = {
    # TODO define base user here (users.users.marvin = {...})
    home-manager.users.marvin = {
      # TODO define common user settings here
    };
  };
}
