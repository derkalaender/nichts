{
  inputs,
  lib,
  ...
}: {
  # Need to declare deploy output an option to allow merging
  options.flake.deploy = lib.mkOption {
    description = "Instantiated deploy-rs deployments.";
    type = with lib.types; lazyAttrsOf raw;
    default = {};
  };

  config = {
    flake-file.inputs = {
      deploy-rs.url = "github:serokell/deploy-rs";
    };

    nichts.overlays = [
      (final: prev: {
        deploys-rs = {
          inherit (final) deploy-rs;
          lib = inputs.deploy-rs.lib;
        };
      })
    ];

    # Generic deploy-rs options
    flake.deploy = {
      sshUser = "root";
      user = "root";
      interactiveSudo = false;
      autoRollback = true;
      magicRollback = true;
      activationTimeout = 300;
    };
  };
}
