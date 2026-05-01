{inputs, ...}: {
  flake-file.inputs = {
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  nichts.aspects.browser.homeManager = {pkgs, ...}: let
    chrome = pkgs.google-chrome;
  in {
    imports = [
      inputs.zen-browser.homeModules.default
    ];

    programs.zen-browser = {
      enable = true;
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
