{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: let
  inherit (lib) genAttrs mapAttrs;

  nichts = config.nichts;

  # A host is: the always-on modules, its own modules, the NixOS side of every
  # user it lists, and Home Manager for those same users.
  mkHost = name: host:
    lib.nixosSystem {
      specialArgs = {inherit nichts;};

      modules = [
        {
          imports =
            [nichts.modules.nixos.default host.module.nixos]
            ++ map (user: nichts.entities.users.${user}.module.nixos) host.users;

          networking.hostName = host.hostname;

          home-manager = {
            # Home Manager modules are also picked by name from nichts, so
            # `nichts` has to reach inside Home Manager too.
            extraSpecialArgs.nichts = nichts;

            users = genAttrs host.users (user: {
              imports = [
                nichts.modules.home.default
                host.module.home
                nichts.entities.users.${user}.module.home
              ];
            });
          };
        }

        inputs.nixpkgs.nixosModules.readOnlyPkgs

        # Use pkgs from flake-parts, so overlays and nixpkgs config carry over.
        {nixpkgs.pkgs = withSystem host.system ({pkgs, ...}: pkgs);}
      ];
    };
in {
  flake.nixosConfigurations = mapAttrs mkHost nichts.entities.hosts;
}
