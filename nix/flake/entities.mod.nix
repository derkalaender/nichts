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
    str
    submodule
    ;

  # A host is NixOS, a user is Home Manager.
  mkModuleOption =
    description:
    mkOption {
      inherit description;
      type = deferredModule;
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
              module = mkModuleOption "The host's NixOS module.";

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
        nichts.entities.hosts.<name>.users. The account fields are data; `module`
        is Home Manager. A password is supplied by the host.
      '';
      type = attrsOf (
        submodule (
          { name, ... }: {
            options = {
              module = mkModuleOption "The user's Home Manager module.";

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
            };
          }
        )
      );
      default = { };
    };
  };
}
