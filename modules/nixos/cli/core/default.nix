{ pkgs, ... }:
{
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
  ];
}
