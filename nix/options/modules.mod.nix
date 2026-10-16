{
  lib,
  moduleLocation,
  ...
}:
let
  inherit (lib) mkOption;
  inherit (lib.types) attrsOf deferredModule submodule;

  # `key` makes the module system deduplicate (a host and a user may both want
  # `desktop`), `_class` makes a wrong class an error, `_file` points errors at the
  # unit.
  wrap =
    { class, path }:
    value: rec {
      _file = "${toString moduleLocation}#${path}";
      key = _file;
      _class = class;
      imports = [ value ];
    };

  classOption =
    { class, path }:
    mkOption {
      description = "The ${class} side of this unit.";
      type = deferredModule;
      default = { };
      apply = wrap { inherit class path; };
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
            nixos = classOption {
              class = "nixos";
              path = "nichts.modules.${name}.nixos";
            };

            home = classOption {
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
