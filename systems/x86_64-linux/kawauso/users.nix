{config, ...}: let
  rdpUser = "otta";
in {
  # Declarative user management
  users.mutableUsers = false;

  users.users.dot = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."user_passwords/dot".path;
    description = "Dot";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINTyrsqSn9oAlqyThh1VoIqLoOzNV5a9IAeERC09fAFU"
    ];
  };

  users.users.${rdpUser} = {
    isNormalUser = true;
    description = "Remote Deployment User";
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbcTKryZ2Nrdt+40qcW4bCc/ghbumiwCTzwcwcEwSgR colmena-access"
    ];
  };

  # Allow non-interactive sudo for remote deployment user (passwordless)
  # This is needed for the deployment-tool to perform a non-interactive deployment
  security.sudo.extraRules = [
    {
      users = [rdpUser];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
