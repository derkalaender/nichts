{ lib, pkgs, ... }:
with lib;
{
  # Yeet perl
  environment.defaultPackages = [ ];

  # Default cli packages that every system should have
  environment.systemPackages = with pkgs; [
    coreutils-full
    neovim
    nano
    wget
    curl
    git
    dig
    htop
    tree
    unzip
    zip
    time

    unstable.just # task runner, used here in the flake

    unstable.micro # easy visual code editor
  ];

  # Set micro as the default editor. Can be overriden
  environment.variables = {
  	EDITOR = "micro";
  };
}
