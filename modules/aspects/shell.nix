{
  nichts.aspects.core = {
    nixos = {pkgs, ...}: {
      programs.bash.enable = true;
      programs.fish.enable = true;

      # fish as default launched from bash
      # From: https://wiki.nixos.org/wiki/Fish
      programs.bash.interactiveShellInit = with pkgs; ''
        if [[ $(${procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    homeManager = {
      programs.bash.enable = true;
      programs.fish.enable = true;
    };
  };
}
