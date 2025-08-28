{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.nichts; let
  cfg = config.nichts.cli.modern;
in {
  options.nichts.cli.modern = mkEnableOpt "Modern Unix CLI tools";

  config = mkIf cfg.enable {
    # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
    home.packages = with pkgs; [
      asciinema # Terminal recorder
      asciinema-agg # Convert Asciinema recordings to GIFs
      chafa # Terminal image viewer
      cpufetch # Show CPU info
      unstable.croc # Effortless file transfer between computers
      fastfetch # Show system info
      fd # Find alternative
      gping # Modern ping
      hexyl # Hex viewer
      hyperfine # Benchmarking tool
      iperf3 # Network performance tool
      jaq # JSON processor
      procs # Modern process viewer
      rclone # Sync files and directories
      restic # Backup tool
      rsync # File transfer
      sd # sed alternative
      speedtest-go # Network speed test
      timer # Timer
      tldr # Simplified man pages
      tokei # Code statistics
      unzip # Unzip files
      upterm # Terminal session sharing
      wget2 # Upgraded wget
      yq-go # YAML processor
    ];

    programs = {
      aria2 = enabled; # Download manager
      bat =
        enabled
        // {
          # cat alternative
          extraPackages = with pkgs.bat-extras; [
            batgrep
            batwatch
            prettybat
          ];
        };
      bottom = enabled;
      dircolors =
        enabled
        // {
          # ls colors
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
          settings = {
            # TODO configure colors
          };
        };
      eza = enabled; # ls alternative
      fzf =
        enabled
        // {
          # Fuzzy finder
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };
      git = enabled; # Git TODO configure
      gitui = enabled; # Git UI
      gpg = enabled; # GPG TODO configure
      ripgrep = enabled; # grep alternative
      yazi =
        enabled
        // {
          # Terminal file manager
          enableBashIntegration = true;
          enableFishIntegration = true;
          enableZshIntegration = true;
        };
      yt-dlp =
        enabled
        // {
          # YouTube downloader
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
      zoxide = {
        # cd alternative
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableZshIntegration = true;
        # Replace cd with z and add cdi to access zi
        options = ["--cmd cd"];
      };
    };
  };
}
