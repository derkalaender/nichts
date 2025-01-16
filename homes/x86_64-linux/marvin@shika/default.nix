{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib.nichts; {
  imports = [
    ./sops.nix
  ];

  # Include man-pages
  programs.man = enabled;
  manual.manpages = enabled;
  manual.html = enabled;

  nichts.cli.nix-tooling = enabled;
  nichts.cli.modern = enabled;
  nichts.editor.helix = enabled;
  nichts.editor.jetbrains = enabled;
  nichts.editor.vscode = enabled;
  nichts.shell.fish = enabled;

  home.packages = with pkgs; [
    unstable.vesktop # Discord modded client
    # insomnia
    # vlc
    unstable.gitkraken # Git client
    unstable.termius # SSH client
    unstable.google-chrome
    unstable.steam
  ];

  # Modded Spotify
  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in
    enabled
    // {
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

  # Autostart Discord
  xdg.autoStart = {
    packages = with pkgs; [
      unstable.discord
    ];
  };
}
