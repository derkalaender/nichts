{
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkOption types;

  # https://github.com/NixOS/nixpkgs/blob/3ceaaa8bc963ced4d830e06ea2d0863b6490ff03/nixos/modules/misc/nixpkgs.nix#L47-L52
  overlayType = lib.mkOptionType {
    name = "nixpkgs-overlay";
    description = "nixpkgs overlay";
    check = lib.isFunction;
    merge = lib.mergeOneOption;
  };
in
{
  options.nichts.overlays = mkOption {
    description = "Overlays to apply to nixpkgs.";
    type = types.listOf overlayType;
    default = [ ];
  };

  config.perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true; # Allow all unfree packages by default
      config.permittedInsecurePackages = [ "electron-39.8.10" ]; # For bitwarden
      overlays = config.nichts.overlays;
    };
  };
}
