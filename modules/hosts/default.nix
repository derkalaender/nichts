{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption mapAttrs;
in {
  options = {
    nichts.hosts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          system = mkOption {
            type = types.enum (import inputs.systems);
            description = "The system type of the host, e.g. x86_64-linux.";
          };
        };
      });
      description = "A set of hosts to be available as nixos configurations.";
    };
  };

  config = {
    flake.nixosConfigurations = let
      mkHost = name: cfg: let
        inherit (inputs) nixpkgs;
      in
        nixpkgs.lib.nixosSystem {
          inherit (cfg) system;
          specialArgs = {
            inherit (cfg) system;
            host = name;
          };
          modules = [
            config.flake.modules.nixos.core
            config.flake.modules.nixos."host_${name}"
          ];
        };
    in
      mapAttrs mkHost config.nichts.hosts;
  };
}
