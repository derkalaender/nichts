{
  lib,
  config,
  ...
}:
with lib;
with lib.nichts; let
  cfg = config.nichts.shell.fish;
in {
  options.nichts.shell.fish = mkEnableOpt "Fish shell";

  # TODO
  config = mkIf cfg.enable {
    programs.fish = enabled;

    # set as default for Ghostty
    programs.ghostty = {
      enableFishIntegration = true;
      settings.command = "${config.programs.fish.package}/bin/fish --login --interactive";
    };
  };
}
