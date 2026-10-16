{
  lib,
  moduleLocation,
  ...
}: let
  inherit (lib) mkOption singleton;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.types) deferredModule lazyAttrsOf;

  # Modules are addressed by name, and the same module is often wanted twice:
  # a host and one of its users may both ask for `desktop`. flake-parts sets
  # `_file` on its own module outputs but no `key`, and `key` is what makes the
  # module system deduplicate, so we set both here (plus `_class`, so importing
  # a Home Manager module into NixOS is an error instead of a silent no-op).
  wrap =
    {class, path}:
    name: value: rec {
      _file = "${toString moduleLocation}#${path}.${name}";
      key = _file;
      _class = class;
      imports = [value];
    };
in {
  options.nichts.modules = {
    nixos = mkOption {
      description = "NixOS modules, addressable by name as nichts.modules.nixos.<name>.";
      type = lazyAttrsOf deferredModule;
      default = {};
      apply = mapAttrs (wrap {class = "nixos"; path = "nichts.modules.nixos";});
    };

    home = mkOption {
      description = "Home Manager modules, addressable by name as nichts.modules.home.<name>.";
      type = lazyAttrsOf deferredModule;
      default = {};
      apply = mapAttrs (wrap {class = "homeManager"; path = "nichts.modules.home";});
    };
  };
}
