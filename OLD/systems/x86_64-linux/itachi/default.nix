{
  lib,
  pkgs,
  ...
}:
with lib.nichts; {
  imports = [
    ./wsl.nix
    ./users.nix
    ./sops.nix
    ./ssh-agent.nix
  ];

  nichts.shell.fish = enabled;

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

  # Enable JLink
  programs.jlink = {
    enable = true;
    trustedUsers = [
      "marvin"
    ];
  };

  system.stateVersion = "23.11";
}
