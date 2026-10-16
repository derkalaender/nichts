{
  nichts.modules.nixos.shell = {pkgs, ...}: {
    programs.bash.enable = true;
    programs.fish.enable = true;

    # This is kind of buggy, so disabled for now
    # Instead, we have the terminal emulator launch the preferred shell

    # # fish as default launched from bash
    # # From: https://wiki.nixos.org/wiki/Fish
    # programs.bash.interactiveShellInit = with pkgs; ''
    #   if [[ $(${procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    #   then
    #     shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
    #     exec ${fish}/bin/fish $LOGIN_OPTION
    #   fi
    # '';
  };

  nichts.modules.home.shell = {
    programs.bash.enable = true;
    programs.fish.enable = true;

    # Nushell
    programs.nushell.enable = true;
    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
