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
      deploy-rs = {
        url = "github:serokell/deploy-rs";
        inputs.nixpkgs.follows = "nixpkgs";
      };
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
      sshUser = "deploy";
      sshOpts = ["-A"]; # Activate agent forwarding
      user = "root";
      interactiveSudo = false;
      autoRollback = true;
      magicRollback = true;
      activationTimeout = 300;
    };

    # Allow securely and remotely deploying NixOS on this system using deploy-rs.
    # This creates a special deploy user with limited privileges for this purpose.

    nichts.aspects.remote-deploy.nixos = {
      users.users.deploy = {
        description = "System deploy user";
        isNormalUser = true;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkj75RIzUSmFX33FFYAc8Ek6V0HpeTqrZel6T4GL8XL" # Deploy RS
        ];

        extraGroups = ["wheel"];
      };

      # Enables sudo with SSH key
      security.pam.services.sudo.sshAgentAuth = true;
      security.pam.sshAgentAuth.enable = true;

      # Restrict commands deploy user can run with sudo
      security.sudo.extraRules = [
        {
          users = ["deploy"];
          commands = [
            {command = "/nix/store/*-activatable-nixos-system-*/activate-rs";}
            {command = "/run/current-system/sw/bin/rm /tmp/deploy-rs-canary-*";}
          ];
        }
      ];
    };
  };
}
