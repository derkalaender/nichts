{
  config,
  self,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.nichts.lib = mkOption {
    description = "Nichts library functions, shared by every flake module.";
    type = with types; attrsOf raw;
    default = { };
  };

  config = {
    # nix/lib holds plain Nix (functions); this is where it becomes available as
    # nichts.lib. `modules` is the unit registry below, so nichts.lib.units can
    # transpose it without every import having to pass it in.
    nichts.lib = import ../lib {
      inherit self lib;
      modules = config.nichts.modules;
    };

    # Make the flake's nichts config available as a module argument everywhere
    # ("nichts" is the flake's config.nichts, so a NixOS module argument named
    # nichts cannot shadow it with something different).
    _module.args.nichts = config.nichts;
  };
}
