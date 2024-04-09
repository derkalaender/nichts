# Adds unstable packages to be directly accessible under `pkgs.unstable.x`
{ channels, ... }:

final: prev: {
  inherit (channels) unstable;
}
