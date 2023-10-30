{ pkgs, ... }:

let
  username = "marvin";
  homeDirectory = "/home/${username}";
in

{
  # Also allow unfree software for Home Manager
  nixpkgs.config.allowUnfree = true;

  # Include man-pages
  manual.manpages.enable = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  home = {
    inherit username homeDirectory;
    stateVersion = "23.05";

    packages = (with pkgs; [
      bottom
      unzip
      google-chrome
      vscode
      spotify
      spicetify-cli
      discord
      gitkraken
      steam
      nil
      go
      killall
      prettyping
      cowsay
      dig
      docker-compose
      insomnia
      vlc
      android-studio
    ]) ++ (with pkgs.jetbrains; [
      idea-ultimate
      goland
      pycharm-professional
      phpstorm
      clion
    ]);
  };
}
