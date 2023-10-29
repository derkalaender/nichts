{config, lib, ...}:
with lib;
let cfg = config.my.defaults.home-manager;
in
{

  options.my.defaults.home-manager = { enable = mkEnableOption "Home Manager defaults"; };

  config = mkIf cfg.enable {
    home-manager = {
      users.marvin = import ../../home/home.nix;
      # Install to default profile directory for better support
      useUserPackages = true;
    };
  };
}