{
  flake.modules.nixos.core = {
    lib,
    inputs,
    pkgs,
    ...
  }: let
    inherit (lib) mapAttrs mapAttrsToList filterAttrs const isType;

    registryMap = inputs |> filterAttrs (const <| isType "flake");
  in {
    imports = [inputs.nix-index-database.nixosModules.nix-index];

    # Configure nix itself. Flakes, GC, etc.
    nix = {
      # Get settings from flake.nix
      settings = (import (lib.nichts.fs.get-file "flake.nix")).nixConfig;

      # Periodically gets rid of duplicate files in the store
      optimise.automatic = true;

      # Disable channels
      channel.enable = false;

      # Make flake registry and nix path match flake inputs
      # This way, we can run things like `nix run nixpkgs#cowsay` or `nix run unstable#cowsay`
      registry = registryMap // {default = inputs.nixpkgs;} |> mapAttrs (_: flake: {inherit flake;});
      nixPath = registryMap |> mapAttrsToList (name: value: "${name}=${value}");
    };

    nixpkgs.overlays = [
      # Use Determinate Nix
      inputs.nix.overlays.default
      # Enable nh, which is a nicer frontend for nix
      (final: prev: {
        inherit (prev.unstable) nh;
      })
    ];

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
