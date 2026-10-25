{
  nichts,
  lib,
  ...
}:
{
  nichts.modules.deerlab.nixos = {
    imports = with nichts.lib.units.nixos; [
      openssh
      fail2ban
      remote-deploy
      tailscale
    ];

    # `deerlab._.users` is not imported here: dot and kyson are entities now, wired via nichts.entities.hosts.kawauso.users.

    # nixos-anywhere works by uploading its own public key to the target system
    services.openssh.authorizedKeysInHomedir = lib.mkForce true;
  };
}
