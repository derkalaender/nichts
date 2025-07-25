{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.nichts.desktop;
in {
  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };
  };
}
