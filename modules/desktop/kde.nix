{
  flake.modules.nixos.desktop = {
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    programs.xwayland.enable = true; # XServer compat

    # SSH Agent
    programs.ssh.startAgent = true;
    programs.ssh.enableAskPassword = true;
    environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";
  };
}
