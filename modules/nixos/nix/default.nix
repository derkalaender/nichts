{
  lib,
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

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
