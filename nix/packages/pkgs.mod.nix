{
  config,
  inputs,
  lib,
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

  # Every plain .nix file in here is one package, named after the file. Files
  # ending in .mod.nix are flake modules (this one included), not packages.
  packagePaths = builtins.filter (path: !(lib.hasSuffix ".mod.nix" (baseNameOf path))) (
    lib.filesystem.listFilesRecursive ./.
  );
  nameOf = path: lib.removeSuffix ".nix" (baseNameOf path);
  packageNames = map nameOf packagePaths;

  # Packages that need something which is not a nixpkgs attribute, e.g. a flake
  # input. Everything else resolves from the package set itself.
  extraArgs = system: {
    omp = {
      llm-agents = inputs.llm-agents.packages.${system};
      llmPkgs = inputs.llm-agents.inputs.nixpkgs.legacyPackages.${system};
    };
  };
in
{
  options.nichts.overlays = mkOption {
    description = "Overlays to apply to nixpkgs.";
    type = types.listOf overlayType;
    default = [ ];
  };

  config = {
    # The single place the packages are instantiated: once per system, in the
    # overlay. packages.<system> below is taken from the very same set.
    nichts.overlays =
      lib.optional
        (lib.assertMsg (
          lib.unique packageNames == packageNames
        ) "nix/packages contains two packages with the same name: ${toString packageNames}")
        (
          final: prev:
          lib.listToAttrs (
            map (path: {
              name = nameOf path;
              value = final.callPackage path ((extraArgs prev.stdenv.hostPlatform.system).${nameOf path} or { });
            }) packagePaths
          )
        );

    perSystem = { pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true; # Allow all unfree packages by default
        config.permittedInsecurePackages = [ "electron-39.8.10" ]; # For bitwarden
        overlays = config.nichts.overlays;
      };

      packages = lib.getAttrs packageNames pkgs;
    };
  };
}
