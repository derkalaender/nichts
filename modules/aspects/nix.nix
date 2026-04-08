{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (builtins) mapAttrs;
  inherit (lib) mapAttrsToList filterAttrs const isType;
in {
  flake-file.inputs = {
    # nix.url = "github:DeterminateSystems/nix-src/v3.15.2";
    nix-index-database.url = "github:nix-community/nix-index-database";
  };

  nichts.overlays = [
    # Use Determinate Nix
    # inputs.nix.overlays.default
  ];

  nichts.aspects.core.nixos = {pkgs, ...}: let
    registryMap = inputs |> filterAttrs (const <| isType "flake");
  in {
    imports = [inputs.nix-index-database.nixosModules.default];

    # Configure nix itself. Flakes, GC, etc.
    nix = {
      # Get settings from flake.nix
      settings = config.flake-file.nixConfig;

      # Periodically gets rid of duplicate files in the store
      optimise.automatic = true;

      # Disable channels
      channel.enable = false;

      # TODO: Allow unfree in the registry, see here https://discourse.nixos.org/t/allowunfree-for-flake-registries/74306/8

      # Make flake registry and nix path match flake inputs
      # This way, we can run things like `nix run nixpkgs#cowsay` or `nix run unstable#cowsay`
      registry = registryMap // {default = inputs.nixpkgs;} |> mapAttrs (_: flake: {inherit flake;});
      nixPath = registryMap |> mapAttrsToList (name: value: "${name}=${value}");
    };

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep 5 --keep-since 60d"; # keep at least the last 5 generations and everything from the last 60 days
      };
    };

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;

    environment.systemPackages = with pkgs; [
      nix-output-monitor
      nix-prefetch
    ];
  };
}
