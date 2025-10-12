{
  self,
  config,
  ...
}: let
  flakeConfig = config.flake;
in {
  # Host-specific user configuration for loading additional modules
  flake.modules.nixos.host_shika = {config, ...}: {
    imports = [
      flakeConfig.modules.nixos.user_marvin
    ];

    home-manager.users.marvin = {
      imports = ["${self}/OLD/homes/x86_64-linux/marvin@shika"];
    };

    # Declarative user management
    users.mutableUsers = false;

    # Define a user account
    users.users.marvin = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets."user_passwords/marvin".path;
      description = "Marvin";
      extraGroups = ["networkmanager" "wheel" "docker" "gamemode"];
    };
  };
}
