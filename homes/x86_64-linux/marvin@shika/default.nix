{ pkgs, ... }:
{
  # Also allow unfree software for Home Manager
  # nixpkgs.config.allowUnfree = true;

  # Include man-pages
  # manual.manpages.enable = true;

  # Let Home Manager manage itself
  # programs.home-manager.enable = true;

  home.packages = (with pkgs; [
      bottom
      unzip
      unstable.vscode
      # spotify
      unstable.spicetify-cli
      (unstable.discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      # steam
      nil
      killall
      prettyping
      cowsay
      dig
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
