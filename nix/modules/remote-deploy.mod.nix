{
  nichts.modules.nixos.remote-deploy = {
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
}
