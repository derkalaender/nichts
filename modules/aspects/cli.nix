{lib, ...}: let
  inherit (lib) mkForce;
in {
  nichts.aspects.core = {
    nixos = {pkgs, ...}: {
      # Yeet perl (as much as possible)
      environment.defaultPackages = mkForce [];
      documentation.info.enable = false;
      documentation.nixos.enable = false;

      environment.systemPackages = with pkgs; [
        # Editors
        nano
        micro
        helix

        # Networking
        wget
        curl
        git
        dig
        rclone
        restic
        rsync
        croc
        gping
        speedtest-go
        iperf3
        upterm
        wget2

        # Data
        jaq
        yq-go
        zip
        unzip
        tree
        hexyl
        fd
        sd
        ripgrep
        tokei
        dust

        # Monitoring
        htop
        bottom
        procs
        time
        hyperfine

        # Secret management / Cryptography
        sops
        age
        openssl

        # Other
        just
        timer
        asciinema
        asciinema-agg
        chafa
        cpufetch
        gpufetch
        fastfetch
        zellij

        # Nix
        nil
        nixd
        alejandra
        devenv
      ];

      programs.direnv.enable = true;
      programs.bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [
          batdiff
          batman
          prettybat
          batwatch
          prettybat
        ];
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
        flags = ["--cmd cd"];
      };
    };

    homeManager = {
      programs.yt-dlp = {
        enable = true;
        settings = {
          audio-format = "best";
          audio-quality = 0;
          embed-chapters = true;
          embed-metadata = true;
          embed-subs = true;
          embed-thumbnail = true;
          remux-video = "aac>m4a/mov>mp4/mkv";
          sponsorblock-mark = "sponsor";
          sub-langs = "all";
        };
      };

      programs.dircolors = {
        enable = true;
        # ls colors
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        settings = {
          # TODO configure colors
        };
      };
    };
  };
}
