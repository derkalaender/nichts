{
  flake.modules.homeManager.desktop_hyprland = {
    services.mako = {
      enable = true; # Notification daemon
    };
  };
}
