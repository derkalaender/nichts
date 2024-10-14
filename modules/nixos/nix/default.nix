{
  lib,
  pkgs,
  inputs,
  ...
}:
with lib.nichts; {
  # Configure nix itself. Flakes, GC, etc.
  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      auto-optimise-store = true; # Gets rid of duplicate files in the store
    };

    # Disable channels
    channel = disabled;
    # Make flake registry and nix path match flake inputs
    # This way, we can run things like `nix run nixpkgs#cowsay` or `nix run unstable#cowsay`
    registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;
    nixPath = lib.mapAttrsToList (name: _: "${name}=flake:${name}") inputs;

    # not needed because of nh below
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 30d";
    # };
  };

  # Enable nh, which is a nicer frontend for nix
  programs.nh = enabled // {
    package = pkgs.unstable.nh;
    clean = enabled // {
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 30d"; # keep at least the last 5 generations and everything from the last 30 dayss
    };
  };
}
