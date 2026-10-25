{
  config,
  lib,
  ...
}:
{
  # nichts.modules.<name>.{nixos,home}, projected onto one class:
  #   imports = with nichts.lib.units.nixos; [boot cli];
  nichts.lib.units = {
    nixos = lib.mapAttrs (_: unit: unit.nixos) config.nichts.modules;
    home = lib.mapAttrs (_: unit: unit.home) config.nichts.modules;
  };
}
