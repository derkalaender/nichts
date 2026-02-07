{
  nichts,
  lib,
  ...
}: {
  nichts.aspects.deerlab = {
    includes = with nichts.aspects; [
      deerlab._.users
      openssh
      fail2ban
      remote-deploy
      tailscale
    ];

    nixos = {
      # nixos-anywhere works by uploading its own public key to the target system
      services.openssh.authorizedKeysInHomedir = lib.mkForce true;
    };
  };
}
