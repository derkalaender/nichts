{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options.nichts.lib = mkOption {
    description = "Nichts library.";
    type = with types; attrsOf raw;
    default = {};
  };

  # Make nichts config available as module argument everywhere
  config._module.args.nichts = config.nichts;
}
