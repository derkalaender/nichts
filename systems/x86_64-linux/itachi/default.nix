{
  lib,
  pkgs,
  ...
}:
with lib.nichts; {
  imports = [
    ./wsl.nix
    ./users.nix
  ];

  boot.enableContainers = false;

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

  # Dynamic linking
  programs.nix-ld.enable = true;

  system.stateVersion = "23.11";
}
