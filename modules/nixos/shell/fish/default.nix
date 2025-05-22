{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.nichts; let
  cfg = config.nichts.shell.fish;
in {
  options.nichts.shell.fish = mkEnableOpt "Fish shell";

  # TODO
  config = mkIf cfg.enable {
    # This is needed to get vendor completions
    programs.fish = enabled;

    # fish as default launched from bash
    # From: https://wiki.nixos.org/wiki/Fish
    programs.bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
  };
}
