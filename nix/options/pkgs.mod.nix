{
  config,
  inputs,
  lib,
  ...
}:
{
  # Which systems the flake generates per-system outputs for.
  systems = lib.mkDefault lib.systems.flakeExposed;

  # The one place nixpkgs is instantiated for per-system outputs.
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true; # Allow all unfree packages by default
      config.permittedInsecurePackages = [ "electron-39.8.10" ]; # For bitwarden
      overlays = config.nichts.overlays;
    };
  };
}
