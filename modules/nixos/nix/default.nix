{
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mapAttrs mapAttrsToList filterAttrs const isType;

  caches = [
    ["https://install.determinate.systems" "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="]
  ];

  registryMap = inputs |> filterAttrs (const <| isType "flake");
in {
  # Configure nix itself. Flakes, GC, etc.
  nix = {
    settings = {
      # Enable Flakes and new nix cmd
      experimental-features = ["nix-command" "flakes" "pipe-operators"];
      # Give anyone with root access special permissions when talking to the Nix daemon
      trusted-users = ["root" "@wheel"];

      warn-dirty = false;
      show-trace = true;

      # https://determinate.systems/posts/changelog-determinate-nix-352/
      lazy-trees = true;

      extra-substituters = caches |> map (cache: builtins.elemAt cache 0);
      extra-trusted-public-keys = caches |> map (cache: builtins.elemAt cache 1);
    };

    # Periodically gets rid of duplicate files in the store
    optimise.automatic = true;
    # Don't remove any dependencies needed to build alive (non-GC'd) packages
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    # Disable channels
    channel.enable = false;
    # Make flake registry and nix path match flake inputs
    # This way, we can run things like `nix run nixpkgs#cowsay` or `nix run unstable#cowsay`
    registry = registryMap // {default = inputs.nixpkgs;} |> mapAttrs (_: flake: {inherit flake;});
    nixPath = registryMap |> mapAttrsToList (name: value: "${name}=${value}");
  };

  # Enable nh, which is a nicer frontend for nix
  programs.nh = {
    enable = true;
    package = pkgs.unstable.nh;
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 60d"; # keep at least the last 5 generations and everything from the last 60 dayss
    };
  };
}
