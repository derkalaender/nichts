{
  nichts,
  lib,
  withSystem,
  ...
}:
let
  inherit (lib) singleton;
in
{
  perSystem = { pkgs, ... }: {
    packages = {
      nuvio = pkgs.callPackage ./nuvio.nix { };
    };
  };

  nichts.overlays = singleton (
    final: prev:
    (withSystem prev.stdenv.hostPlatform.system (
      { config, ... }: {
        inherit (config.packages) nuvio;
      }
    ))
  );
}
