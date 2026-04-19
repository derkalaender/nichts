{lib, ...}: let
  inherit (lib) mkForce;
in {
  nichts.aspects.bitwarden = {
    nixos = {
      # Disable the default SSH agent since Bitwarden will provide one
      programs.ssh = {
        startAgent = mkForce false;
        enableAskPassword = mkForce false;
      };
    };

    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        bitwarden-desktop
      ];

      # Use Bitwarden as SSH agent
      # See https://github.com/bitwarden/clients/blob/2109092a9443d178e3c1be2a74819b85a390c0d4/apps/desktop/desktop_native/core/src/ssh_agent/unix.rs
      # Bitwarden sees BITWARDEN_SSH_AUTH_SOCK pointing to the SSH agent socket
      # Use standard XDG_RUNTIME_DIR for the socket location instead of Bitwarden's horrible default choice of putting it into the home directory
      # TODO wrap bitwarden-desktop instead so only it gets the BITWARDEN_SSH_AUTH_SOCK variable set. I cannot get this to work right now because the autostart will ignore the wrapped version.

      # For shell sessions
      home.sessionVariables = {
        BITWARDEN_SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/bitwarden-ssh-agent";
        # Use Bitwarden's SSH agent for SSH authentication
        SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/bitwarden-ssh-agent";
      };

      # For desktop apps
      systemd.user.sessionVariables = {
        BITWARDEN_SSH_AUTH_SOCK = "%t/bitwarden-ssh-agent";
        # Use Bitwarden's SSH agent for SSH authentication
        SSH_AUTH_SOCK = "%t/bitwarden-ssh-agent";
      };
    };
  };
}
