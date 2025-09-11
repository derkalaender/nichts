{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption mapAttrs';
in {
  options = {
    nichts.users = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          # TODO
        };
      });
      description = "A set of users to be available as imports for hosts";
    };
  };

  config = {
    # Imports the core home manager module for each user
    flake.modules.nixos = let
      mkUser = name: cfg: {
        name = "user_${name}";
        value = {
          home-manager.users."${name}" = {
            imports = [config.flake.modules.homeManager.core];
          };
        };
      };
    in
      mapAttrs' mkUser config.nichts.users;
  };
}
