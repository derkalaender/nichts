{ lib, pkgs, ... }:
with lib.nichts;
{
  imports = [
  	./sops.nix
  ];

  # Include man-pages
  programs.man = enabled;
  manual.manpages = enabled;
  manual.html = enabled;

  nichts.cli.modern = enabled;
  nichts.editor.helix = enabled;
  nichts.shell.fish = enabled;

  home.packages = (with pkgs; [
      # containers
      dive
      docker-compose
      podman-compose
      podman-tui
      runc
  ]);
}
