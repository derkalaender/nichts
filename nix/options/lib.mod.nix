{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.nichts.lib = mkOption {
    description = "Library functions, contributed by modules under nix/lib.";
    type = with types; attrsOf raw;
    default = { };
  };

  config = {
    # Make the flake's nichts config available as a module argument everywhere
    # ("nichts" is the flake's config.nichts, so a NixOS module argument named
    # nichts cannot shadow it with something different).
    _module.args.nichts = config.nichts;
  };
}
