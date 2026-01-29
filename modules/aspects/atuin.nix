{
  lib,
  nichts,
  ...
}: let
  inherit (builtins) listToAttrs;
  inherit (lib) nameValuePair;
  inherit (nichts.lib) fs;
in {
  nichts.aspects.atuin.homeManager = {config, ...}: {
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
        session_path = config.sops.secrets."atuin/session".path;
        key_path = config.sops.secrets."atuin/key".path;
      };
    };

    sops.secrets =
      ["atuin/key" "atuin/session"]
      |> map (secret: nameValuePair secret {sopsFile = fs.secret "atuin.yaml";})
      |> listToAttrs;
  };
}
