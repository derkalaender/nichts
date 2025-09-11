{
  self,
  config,
  ...
}: {
  # Host-specific user configuration for loading additional modules
  flake.modules.nixos.host_shika = {
    imports = [
      config.flake.modules.nixos.user_marvin
    ];

    home-manager.users.marvin = {
      imports = ["${self}/OLD/homes/x86_64-linux/marvin@shika"];
    };
  };
}
