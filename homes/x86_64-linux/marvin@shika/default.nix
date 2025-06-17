{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib.nichts; {
  imports = [
    ./sops.nix
  ];

  # Include man-pages
  programs.man = enabled;
  manual.manpages = enabled;
  manual.html = enabled;

  nichts.cli.nix-tooling = enabled;
  nichts.cli.modern = enabled;
  nichts.cli.atuin = {
    enable = true;
    sync = true;
  };
  nichts.editor.helix = enabled;
  nichts.editor.jetbrains = enabled;
  nichts.editor.vscode = enabled;
  nichts.shell.fish = enabled;
  nichts.spotify.enable = true;
  nichts.gaming.enable = true;

  nichts.git = {
    enable = true;
    sshSigningKey = config.sops.secrets.ssh_public.path;
    username = "derkalaender";
    email = "git@derkalaender.de";
  };

  home.packages = with pkgs; [
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    # insomnia
    vlc
    gitkraken # Git client
    unstable.termius # SSH client
    (unstable.google-chrome.override
      {
        commandLineArgs = [
          # Enable Wayland, fixes some issues, e.g. allows dragging tabs around
          "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true"
        ];
      })
    unstable.distrobox # Easy dev environments
    unstable.anki
    rclone

    eduvpn-client

    uv
  ];

  # Ghostty Terminal
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
