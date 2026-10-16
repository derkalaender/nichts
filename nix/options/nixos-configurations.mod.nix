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
  mkUserAccounts =
    host:
    { config, ... }:
    {
      users.users = genAttrs host.users (
        userName:
        let
          user = nichts.entities.users.${userName};
        in
        {
          inherit (user) description isNormalUser extraGroups;
        }
        // optionalAttrs (user.hashedPasswordSecret != null) {
          hashedPasswordFile = config.sops.secrets.${user.hashedPasswordSecret}.path;
        }
        // optionalAttrs (user.authorizedKeys != [ ]) {
          openssh.authorizedKeys.keys = user.authorizedKeys;
        }
      );
    };

  # A host is: the always-on modules, its own modules, the NixOS side of every
  # user it lists, and Home Manager for those same users.
  mkHost =
    name: host:
    lib.nixosSystem {
      specialArgs = { inherit nichts; };

      modules = [
        {
          imports = [
            nichts.modules.default.nixos
            host.module.nixos
          ]
          ++ map (user: nichts.entities.users.${user}.module.nixos) host.users;

          networking.hostName = host.hostname;

          home-manager = {
            # Home Manager modules are also picked by name from nichts, so
            # `nichts` has to reach inside Home Manager too.
            extraSpecialArgs.nichts = nichts;

            users = genAttrs host.users (user: {
              imports = [
                nichts.modules.default.home
                host.module.home
                nichts.entities.users.${user}.module.home
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
