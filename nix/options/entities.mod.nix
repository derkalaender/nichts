{
  lib,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types)
    attrsOf
    bool
    deferredModule
    listOf
    nullOr
    str
    submodule
    ;

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
          default = { };
        };

        home = mkOption {
          description = "Home Manager module.";
          type = deferredModule;
          default = { };
        };
      };
    };
    default = { };
  };
in
{
  options.nichts.entities = {
    hosts = mkOption {
      description = "Hosts. Every host becomes a flake.nixosConfigurations entry.";
      type = attrsOf (
        submodule (
          { name, ... }: {
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
                default = [ ];
              };
            };
          }
        )
      );
      default = { };
    };

    users = mkOption {
      description = ''
        Users. A host picks the ones it provides through
        nichts.entities.hosts.<name>.users.

        What makes a user an *account* is declared here as data (description,
        groups, SSH keys, which secret holds the password), so every host wires
        accounts the same way and the flake can reason about its users without
        reading module bodies. Everything else about a user is a module:
        module.nixos for NixOS configuration, module.home for Home Manager.
      '';
      type = attrsOf (
        submodule (
          { name, ... }: {
            options = {
              module = moduleOption;

              description = mkOption {
                description = "GECOS field of the account.";
                type = str;
                default = name;
              };

              isNormalUser = mkOption {
                description = "Whether this is a login account rather than a system user.";
                type = bool;
                default = true;
              };

              extraGroups = mkOption {
                description = "Groups the account is added to, on top of its own.";
                type = listOf str;
                default = [ ];
              };

              authorizedKeys = mkOption {
                description = "SSH public keys allowed to log in as this account.";
                type = listOf str;
                default = [ ];
              };

              hashedPasswordSecret = mkOption {
                description = ''
                  Name of the sops secret holding this account's hashed password;
                  config.sops.secrets.<name>.path becomes hashedPasswordFile. The
                  secret itself is declared where its file lives, by the host or by
                  the user. null for an account without a password.
                '';
                type = nullOr str;
                default = "user_passwords/${name}";
              };
            };
          }
        )
      );
      default = { };
    };
  };
}
