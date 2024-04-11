# TODO refactor this old legacy code

{ lib, config, ... }:
with lib;
with lib.nichts;
let
  cfg = config.nichts.desktop;
in
{
  options.nichts.desktop = mkEnableOpt "default desktop configuration" // {
    hostname = mkOption {
      type = types.str;
      example = "shika";
      description = "The hostname of the system";
    };
  };

  config = mkIf cfg.enable {
    # Networking
    networking = {
      hostName = cfg.hostname;
      nameservers = [ "1.1.1.1" "1.0.0.1" ];
    };

    # Sound
    sound = enabled;
    hardware.pulseaudio = disabled;
    security.rtkit = enabled;
    services.pipewire = enabled // {
      alsa = enabled // { support32Bit = true; };
      pulse = enabled;
    };

    # Locale
    time.timeZone = "Europe/Berlin";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_IDENTIFICATION = "de_DE.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "de_DE.UTF-8";
    };
  };
}
