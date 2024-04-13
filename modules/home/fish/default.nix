{ lib, config, ... }:
with lib;
with lib.nichts;
let
  cfg = config.nichts.fish;
in
{
  options.nichts.fish = mkEnableOpt "Fish shell";

  # TODO
  config = mkIf cfg.enable {
    programs.fish = enabled;
  };
}
