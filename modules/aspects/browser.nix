{inputs, ...}: {
  flake-file.inputs = {
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  nichts.aspects.browser.homeManager = {pkgs, ...}: let
    chrome = pkgs.google-chrome.override {
      commandLineArgs = [
        # Enable Wayland, fixes some issues, e.g. allows dragging tabs around
        "--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true"
      ];
    };
  in {
    imports = [
      inputs.zen-browser.homeModules.default
    ];

    programs.zen-browser.enable = true;

    home.packages = [
      chrome
    ];
  };
}
