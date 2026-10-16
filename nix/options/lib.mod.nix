{
  config,
  inputs,
  lib,
  self,
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
    # nix/lib holds plain Nix (functions, constants); this is where it becomes
    # available as nichts.lib, which modules reach through the `nichts` argument.
    nichts.lib = import ../lib { inherit self lib inputs; };

    # Make the flake's nichts config available as a module argument everywhere
    # ("nichts" is the flake's config.nichts, so a NixOS module argument named
    # nichts cannot shadow it with something different).
    _module.args.nichts = config.nichts;
  };
}
