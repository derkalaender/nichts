# Locale, timezone, keyboard layout, etc.
{lib, ...}:
with lib;
with nichts; {
  # TODO enable automatic timezone detection
  time.timeZone = "Europe/Berlin";

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
  services.xserver.xkb = { # desktop
    layout = "de";
    variant = "";
  };
  console.keyMap = "de"; # console
}
