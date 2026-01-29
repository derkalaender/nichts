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

        wget
        curl
        git
        dig
        htop
        tree
        unzip
        zip
        time

        just

        asciinema
        asciinema-agg
        chafa
        cpufetch
        gpufetch
        fastfetch
        fd
        gping
        hexyl
        hyperfine
        iperf3
        jaq
        procs
        rclone
        restic
        rsync
        ripgrep
        sd
        speedtest-go
        timer
        tokei
        upterm
        wget2
        yq-go

        bottom

        # Nix
        nil
        nixd
        alejandra
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
