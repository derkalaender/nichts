# Shared helpers, exposed as nichts.lib.<name> by nix/options/lib.mod.nix.
{
  self,
  lib,
  modules,
}:
{
  # Paths into this flake's source tree, as strings. Prefer a plain relative path
  # (`./foo`): a path is copied into the store on its own, while a string built
  # from `self` drags the whole source tree in as a build dependency.
  fs = import ./fs.nix { inherit self; };

  # nichts.modules, one class at a time: nichts.lib.units.nixos / .home.
  units = import ./units.nix { inherit lib modules; };
}
