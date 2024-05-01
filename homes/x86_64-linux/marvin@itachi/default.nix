{ lib, pkgs, ... }:
with lib.nichts;
{
  # Include man-pages
  programs.man = enabled;
  manual.manpages = enabled;
  manual.html = enabled;

  nichts.cli-apps.modern = enabled;
  nichts.editor.helix = enabled;
  nichts.fish = enabled;

  home.packages = (with pkgs; [
      killall
      cowsay
      docker-compose
  ]);
}
