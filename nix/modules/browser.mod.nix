{ inputs, ... }: {
  nichts.modules.home.browser =
    { pkgs, ... }:
    let
      chrome = pkgs.google-chrome;
    in
    {
      imports = [
        inputs.zen-browser.homeModules.default
      ];

      programs.zen-browser = {
        enable = true;
        nativeMessagingHosts = [ pkgs.jabref ];
        policies = {
          DisableAppUpdate = true;
          DisableTelemetry = true;
          DisableSetBackground = true;
          OfferToSaveLogins = false; # Bitwarden handles this
        };
        profiles."Default Profile".settings = {
          widget.use-xdg-desktop-portal.file-picker = 1; # Use KDE file picker
        };
      };

      home.packages = [
        chrome
      ];
    };
}
