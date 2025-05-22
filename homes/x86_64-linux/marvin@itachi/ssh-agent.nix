{...}: {
  # Use SSH agent forwarding from Windows
  home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.ssh/wsl2-ssh-agent.sock";

  # Automatically add keys to the agent
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };
}
