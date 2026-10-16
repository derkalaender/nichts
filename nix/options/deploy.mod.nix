{
  inputs,
  lib,
  ...
}:
{
  options.flake.deploy = lib.mkOption {
    description = "Instantiated deploy-rs deployments.";
    type = with lib.types; lazyAttrsOf raw;
    default = { };
  };

  config = {
    nichts.overlays = [
      (final: prev: {
        deploys-rs = {
          inherit (final) deploy-rs;
          lib = inputs.deploy-rs.lib;
        };
      })
    ];

    # Generic deploy-rs options; per-host deployments live next to their host.
    flake.deploy = {
      sshUser = "deploy";
      sshOpts = [ "-A" ]; # Activate agent forwarding
      user = "root";
      interactiveSudo = false;
      autoRollback = true;
      magicRollback = true;
      activationTimeout = 300;
    };
  };
}
