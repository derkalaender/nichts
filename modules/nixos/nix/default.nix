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
      # Enable Flakes and new nix cmd
      experimental-features = ["nix-command" "flakes"];
      # Give anyone with root access special permissions when talking to the Nix daemon
      trusted-users = ["root" "@wheel"];
    };

    # Periodically gets rid of duplicate files in the store
    optimise.automatic = true;
    # Don't remove any dependencies needed to build alive (non-GC'd) packages
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    # Disable channels
    channel = disabled;
    # Make flake registry and nix path match flake inputs
    # This way, we can run things like `nix run nixpkgs#cowsay` or `nix run unstable#cowsay`
    registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;
    nixPath = lib.mapAttrsToList (name: _: "${name}=flake:${name}") inputs;
  };

  # Enable nh, which is a nicer frontend for nix
  programs.nh =
    enabled
    // {
      package = pkgs.unstable.nh;
      clean =
        enabled
        // {
          dates = "weekly";
          extraArgs = "--keep 5 --keep-since 60d"; # keep at least the last 5 generations and everything from the last 60 dayss
        };
    };
}
