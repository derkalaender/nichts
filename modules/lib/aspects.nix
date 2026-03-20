{
  inputs,
  lib,
  nichts,
  ...
}: let
  inherit (lib) mkOption;
in {
  options = {
    nichts.aspects = mkOption {
      description = "Nichts aspects.";
      type = nichts.lib.aspects.types.aspectsType {};
      default = {};
    };
  };

  config = {
    flake-file.inputs = {
      flake-aspects.url = "github:vic/flake-aspects";
    };

    # Add the flake-aspects lib to nichts lib to make it easily accessible (and only need to instantiate it once)
    nichts.lib.aspects = inputs.flake-aspects.lib lib;
  };
}
