{
  lib,
  ...
}: let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf deferredModule listOf str submodule;

  # Hosts and users are both "an entity with a NixOS module and a Home Manager
  # module". Hosts additionally know their platform and which users they have.
  moduleOption = mkOption {
    description = ''
      The NixOS and Home Manager modules this entity contributes.

      Files that have nothing to say about one side leave that side empty.
    '';
    type = submodule {
      options = {
        nixos = mkOption {
          description = "NixOS module.";
          type = deferredModule;
          default = {};
        };

        home = mkOption {
          description = "Home Manager module.";
          type = deferredModule;
          default = {};
        };
      };
    };
    default = {};
  };
in {
  options.nichts.entities = {
    hosts = mkOption {
      description = "Hosts. Every host becomes a flake.nixosConfigurations entry.";
      type = attrsOf (submodule ({name, ...}: {
        options = {
          module = moduleOption;

          system = mkOption {
            description = "Platform this host is evaluated for.";
            type = str;
            default = "x86_64-linux";
          };

          hostname = mkOption {
            description = "networking.hostName. Defaults to the host's attribute name.";
            type = str;
            default = name;
          };

          users = mkOption {
            description = "Users (nichts.entities.users names) this host provides.";
            type = listOf str;
            default = [];
          };
        };
      }));
      default = {};
    };

    users = mkOption {
      description = "Users. Referenced from nichts.entities.hosts.<name>.users.";
      type = attrsOf (submodule {
        options.module = moduleOption;
      });
      default = {};
    };
  };
}
