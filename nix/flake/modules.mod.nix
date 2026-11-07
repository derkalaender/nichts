{
  lib,
  moduleLocation,
  ...
}:
let
  inherit (lib.fixedPoints) fix;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf deferredModule submodule;

  # `key` makes the module system deduplicate (a host and a user may both want
  # `desktop`), `_class` makes a wrong class an error, `_file` points errors at the
  # unit.
  wrap =
    {
      class,
      path,
    }:
    value:
    fix (module: {
      _file = "${toString moduleLocation}#${path}";
      key = module._file;
      _class = class;
      imports = [
        value
      ];
    });

  mkClassOption =
    {
      class,
      path,
    }:
    mkOption {
      description = "The ${class} side of this unit.";
      type = deferredModule;
      apply = wrap {
        inherit class path;
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
        {
          name,
          config,
          options,
          ...
        }:
        {
          options = {
            nixos = mkClassOption {
              class = "nixos";
              path = "nichts.modules.${name}.nixos";
            };

            home = mkClassOption {
              class = "homeManager";
              path = "nichts.modules.${name}.home";
            };
          };

          # Each home module gets imported in the corresponding NixOS module as a sharedModule.
          # This way, importing the NixOS module also imports the home module.
          config.nixos = mkIf options.home.isDefined {
            home-manager.sharedModules = [ config.home ];
          };
        }
      )
    );
  };
}
