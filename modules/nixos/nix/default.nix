{ pkgs, ... }:
{
  # Configure nix itself. Flakes, GC, etc.
  nix = {
    package = pkgs.unstable.nixUnstable;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true; # Gets rid of duplicate files in the store
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
