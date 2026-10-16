# nichts.modules.<name>.{nixos,home}, projected onto one class:
#   imports = with nichts.lib.units.nixos; [boot cli];
{ lib, modules }: {
  nixos = lib.mapAttrs (_: unit: unit.nixos) modules;
  home = lib.mapAttrs (_: unit: unit.home) modules;
}
