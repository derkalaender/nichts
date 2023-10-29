{config, lib, ...}:
with lib;
let cfg = config.my.defaults.home-manager;
in
{

  options.my.defaults.home-manager = { enable = mkEnableOption "Home Manager defaults"; };

  config = mkIf cfg.home-manager {
    
  }
}