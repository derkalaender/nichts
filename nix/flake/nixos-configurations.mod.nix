{
  config,
  inputs,
  lib,
  withSystem,
  ...
}:
let
  inherit (lib) genAttrs mapAttrs optionalAttrs;

  nichts = config.nichts;

  # The account side of every user the host lists. Passwords are the host's.
  mkUserAccounts = host: {
    users.users = genAttrs host.users (
      userName:
      let
        user = nichts.entities.users.${userName};
      in
      {
        inherit (user) description isNormalUser extraGroups;
      }
      // optionalAttrs (user.authorizedKeys != [ ]) {
        openssh.authorizedKeys.keys = user.authorizedKeys;
      }
    );
  };

  # A host is: the always-on modules, its own module, the account side of every
  # user it lists, and Home Manager for those same users.
  mkHost =
    name: host:
    lib.nixosSystem {
      specialArgs = { inherit nichts; };

      modules = [
        {
          imports = [
            nichts.modules.default.nixos
            {
              # Class-tagged, so the wrong module class is an error.
              _class = "nixos";
              _file = "nichts.entities.hosts.${name}.module";
              imports = [ host.module ];
            }
          ];

          networking.hostName = host.hostname;

          home-manager = {
            # nichts is used inside Home Manager modules too.
            extraSpecialArgs.nichts = nichts;

            users = genAttrs host.users (userName: {
              imports = [
                {
                  _class = "homeManager";
                  _file = "nichts.entities.users.${userName}.module";
                  imports = [ nichts.entities.users.${userName}.module ];
                }
              ];
            });
          };
        }

        (mkUserAccounts host)

        inputs.nixpkgs.nixosModules.readOnlyPkgs

        # Use pkgs from flake-parts, so overlays and nixpkgs config carry over.
        { nixpkgs.pkgs = withSystem host.system ({ pkgs, ... }: pkgs); }
      ];
    };
in
{
  flake.nixosConfigurations = mapAttrs mkHost nichts.entities.hosts;
}
