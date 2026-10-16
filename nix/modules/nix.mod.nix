{
  inputs,
  lib,
  ...
}: let
  inherit (builtins) mapAttrs;
  inherit (lib) mapAttrsToList filterAttrs const isType;

  # The flake's own nixConfig is the single source of truth for the nix settings,
  # so the flake and the installed systems can never disagree. It cannot live in
  # a shared file: the flake parser rejects thunks in nixConfig.
  nixConfig = (import ../../flake.nix).nixConfig;
in {
  nichts.overlays = [
    # Use Lix instead of Nix (https://lix.systems/add-to-config/)
    (final: prev: {
      nix = prev.lixPackageSets.stable.lix;
    })
  ];

  nichts.modules.nixos.nix = {pkgs, ...}: let
    registryMap = inputs |> filterAttrs (const <| isType "flake");
  in {
    imports = [inputs.nix-index-database.nixosModules.default];

    # Configure nix itself. Flakes, GC, etc.
    nix = {
      # Get settings from flake.nix.
      # nixpkgs' nix module also defines these three list settings (notably
      # `substituters = lib.mkAfter [ "https://cache.nixos.org/" ]`), and list
      # options merge by concatenation — which duplicated cache.nixos.org and
      # `root` in the generated /etc/nix/nix.conf. mkForce makes our values win.
      settings = nixConfig // {
        substituters = lib.mkForce nixConfig.substituters;
        trusted-public-keys = lib.mkForce nixConfig.trusted-public-keys;
        trusted-users = lib.mkForce nixConfig.trusted-users;
      };

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
        extraArgs = "--keep 5 --keep-since 30d"; # keep at least the last 5 generations and everything from the last 30 days
      };
    };

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;

    environment.systemPackages = with pkgs; [
      nix-output-monitor
      nix-prefetch
      nix-tree
    ];
  };
}
