{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.nichts.gaming;
in {
  options = {
    nichts.gaming = {
      enable = mkEnableOption "gaming support, games & launchers";
    };
  };

  config = mkIf cfg.enable {
    # This allows games to activate system optimizations
    programs.gamemode.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
    };
  };
}
