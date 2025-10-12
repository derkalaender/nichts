{
  flake.modules.homeManager.desktop_hyprland = {pkgs, ...}: {
    programs.rofi = {
      enable = true;
      terminal = "${pkgs.ghostty}/bin/ghostty";
    };
  };
}
