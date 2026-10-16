{
  self,
  lib,
  inputs,
  ...
}:
{
  fs = import ./fs.nix { inherit self; };
}
