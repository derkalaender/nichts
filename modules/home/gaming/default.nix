{
  lib,
  pkgs,
  config,
  osConfig,
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
    home.packages = let
      lutris-overrides = {
        # Provide steam ourselves based on NixOS system package, so we don't get any conflict
        steamSupport = false;
        extraPkgs = _: [osConfig.programs.steam.package];
      };
    in (
      with pkgs; [
        (lutris.override lutris-overrides) # game launcher for basically everything
        unstable.prismlauncher # minecraft
      ]
    );
  };
}
