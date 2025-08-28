{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge;
  inherit (lib.nichts) fs;
  cfg = config.nichts.cli.atuin;
in {
  options = {
    nichts.cli.atuin = {
      enable = mkEnableOption "Atuin shell history manager";
      sync = mkEnableOption "sync Atuin history across shells";
    };
  };

  config = {
    programs.atuin = {
      enable = cfg.enable;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      settings = mkMerge [
        {
          search_mode = "fuzzy";
          enter_accept = true;
        }
        (mkIf cfg.sync {
          auto_sync = true;
          sync_frequency = "5m";
          sync_address = "https://api.atuin.sh";
          session_path = config.sops.secrets."atuin/session".path;
          key_path = config.sops.secrets."atuin/key".path;
        })
      ];
    };

    sops.secrets = mkIf cfg.sync (
      ["atuin/key" "atuin/session"]
      |> map (name: {
        inherit name;
        value = {
          sopsFile = "${fs.secrets}/atuin.yaml";
        };
      })
      |> builtins.listToAttrs
    );
  };
}
