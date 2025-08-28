{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nichts.spotify;
in {
  options = {
    nichts.spotify.enable = mkEnableOption "spotify with modifications (spicetify)";
  };

  config = mkIf cfg.enable {
    programs.spicetify = let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in {
      enable = true;
      wayland = false; # BUG: ugly titlebar
      enabledExtensions = with spicePkgs.extensions; [
        shuffle # better shuffle algorithm
        songStats # song statistics like dancability, tempo and key
        showQueueDuration # show the duration of the queue
      ];
      enabledCustomApps = with spicePkgs.apps; [
        lyricsPlus # better lyrics
      ];
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
    };
  };
}
