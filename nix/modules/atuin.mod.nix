{
  nichts.modules.atuin.home = { config, lib, ... }: {
    options.nichts.atuin = {
      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to the atuin sync key (set by the user from its own sops secrets)";
      };

      session = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to the atuin sync session (set by the user from its own sops secrets)";
      };
    };

    config = {
      programs.atuin = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = true;
        settings = {
          search_mode = "fuzzy";
          enter_accept = true;

          # Sync settings
          auto_sync = true;
          sync_frequency = "5m";
          session_path = config.nichts.atuin.session;
          key_path = config.nichts.atuin.key;
        };
      };
    };
  };
}
