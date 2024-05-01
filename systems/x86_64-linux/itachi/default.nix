{ lib, ... }:
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

  # Configure console keymap
  console.keyMap = "de";

  # Enable docker & podman
  virtualisation = {
    containers = enabled;
    docker = enabled;
    podman = enabled;
  };

  system.stateVersion = "23.11";
}
