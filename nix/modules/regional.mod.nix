{
  nichts.modules.nixos.regional = {
    # Berlin as default timezone
    time.timeZone = "Europe/Berlin";

    # TODO: Automatically determine TZ based on IP when connecting to network https://wiki.archlinux.org/title/NetworkManager#Automatically_set_the_timezone

    # Lang, want to use US language but for display of dates etc use German formatting
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
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

    # German keyboard layout
    services.xserver.xkb = {
      layout = "de";
      variant = "nodeadkeys";
    };
    console.keyMap = "de";
  };
}
