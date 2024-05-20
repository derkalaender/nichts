{ lib, pkgs, ... }:
with lib.nichts;
{
  imports =
    [
      ./wsl.nix
      ./users.nix
    ];

#  nichts.desktop = enabled // {
#    hostname = "shika";
#  };
  nichts.cli-apps.nix-tooling = enabled;

  boot.enableContainers = false;

  # Configure console keymap
  console.keyMap = "de";

  # Enable docker & podman
  virtualisation = {
    containers = enabled;
    docker = enabled;
    podman = enabled;
    containerd = enabled;
  };
  environment.systemPackages = with pkgs; [
    nerdctl
  ];

  system.stateVersion = "23.11";
}
