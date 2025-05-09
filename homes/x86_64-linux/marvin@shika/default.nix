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
  nichts.spotify.enable = true;

  home.packages = with pkgs; [
    unstable.vesktop # Discord modded client
    # insomnia
    # vlc
    unstable.gitkraken # Git client
    unstable.termius # SSH client
    unstable.google-chrome
    unstable.steam
    unstable.distrobox # Easy dev environments
    unstable.anki
    rclone
  ];

  # Ghostty Terminal
  programs.ghostty = {
    enable = true;
    package = pkgs.unstable.ghostty;
    enableFishIntegration = true;
  };

  # Autostart Discord
  xdg.autoStart = {
    packages = with pkgs; [
      unstable.discord
    ];
  };
}
