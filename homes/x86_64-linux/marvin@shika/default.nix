{ lib, pkgs, ... }:
with lib.nichts;
{
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

  home.packages = (with pkgs; [
      # spotify
      unstable.spicetify-cli
      unstable.vesktop # Discord modded client
      # steam
      # insomnia
      # vlc
    ]);
}
