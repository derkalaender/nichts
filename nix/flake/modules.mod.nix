{
  lib,
  moduleLocation,
  config,
  ...
}:
let
  inherit (lib) mkOption optional;
  inherit (lib.types) attrsOf deferredModule submodule;

  # `key` makes the module system deduplicate (a host and a user may both want
  # `desktop`), `_class` makes a wrong class an error, `_file` points errors at the
  # unit. `couples`: importing the NixOS side also gives every user of that host
  # the Home Manager side.
  wrap =
    {
      name,
      class,
      path,
      couples ? false,
    }:
    value: rec {
      _file = "${toString moduleLocation}#${path}";
      key = _file;
      _class = class;
      imports = [
        value
      ]
      ++ optional couples {
        home-manager.sharedModules = [ config.nichts.modules.${name}.home ];
      };
    };

  mkClassOption =
    {
      name,
      class,
      path,
      couples ? false,
    }:
    mkOption {
      description = "The ${class} side of this unit.";
      type = deferredModule;
      default = { };
      apply = wrap {
        inherit
          name
          class
          path
          couples
          ;
      };
    };
in
{
  options.nichts.modules = mkOption {
    description = ''
      Units, addressed by name: nichts.modules.<name>.{nixos,home}. Import them
      through nichts.lib.units.<class>.
    '';
    type = attrsOf (
      submodule (
        { name, ... }: {
          options = {
            nixos = mkClassOption {
              inherit name;
              class = "nixos";
              path = "nichts.modules.${name}.nixos";
              couples = true;
            };

            home = mkClassOption {
              inherit name;
              class = "homeManager";
              path = "nichts.modules.${name}.home";
            };
          };
        }
      )
    );
    default = { };
  };
}
