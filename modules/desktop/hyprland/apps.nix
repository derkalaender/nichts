{
  flake.modules.homeManager.desktop_hyprland = {pkgs, ...}: {
    services.hyprpolkitagent.enable = true;

    home.packages = with pkgs; [
      nautilus # file manager
      zenity # dialog boxes
      eog # image viewer
    ];
  };
}
