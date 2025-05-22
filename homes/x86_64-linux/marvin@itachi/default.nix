{
  config,
  lib,
  pkgs,
  ...
}:
with lib.nichts; {
  imports = [
    ./sops.nix
    ./ssh-agent.nix
  ];

  # Include man-pages
  programs.man = enabled;
  manual.manpages = enabled;
  manual.html = enabled;

  nichts.cli.modern = enabled;
  nichts.cli.nix-tooling = enabled;
  nichts.editor.helix = enabled;
  nichts.shell.fish = enabled;

  nichts.git = {
    enable = true;
    sshSigningKey = config.sops.secrets.ssh_public.path;
    username = "derkalaender";
    email = "git@derkalaender.de";
  };

  home.packages = with pkgs; [
    # containers
    dive
    docker-compose
    podman-compose
    podman-tui
    runc

    # Git GUI
    gitkraken
  ];
}
