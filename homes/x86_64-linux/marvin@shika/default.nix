{ lib, pkgs, ... }:
with lib.nichts;
{
  # Include man-pages
  programs.man = enabled;
  manual.manpages = enabled;
  manual.html = enabled;

  nichts.cli-apps.modern = enabled;
  nichts.editor.helix = enabled;
  nichts.editor.jetbrains = enabled;
  nichts.fish = enabled;

  home.packages = (with pkgs; [
      unstable.vscode
      # spotify
      unstable.spicetify-cli
      (unstable.discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      # steam
      killall
      cowsay
      docker-compose
      # insomnia
      # vlc
      # android-studio
    ]) ++ (with pkgs.jetbrains; [
      # idea-ultimate
      # goland
      # pycharm-professional
      # phpstorm
      # clion
      # (plugins.addPlugins idea-ultimate [ "github-copilot" ])
    ]);
}
