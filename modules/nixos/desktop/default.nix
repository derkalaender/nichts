{ lib, pkgs, config, ... }:
with lib;
with nichts;
let
  cfg = config.nichts.desktop;
in
{
  options.nichts.desktop = mkEnableOpt "Default desktop configuration";

  config = mkIf cfg.enable {
    # Sound
    # sound = enabled;
    hardware.pulseaudio = disabled;
    security.rtkit = enabled;
    services.pipewire = enabled // {
      alsa = enabled // { support32Bit = true; };
      pulse = enabled;
    };

    # X11 Windowing System
    # TODO replace with Wayland
    services.xserver = enabled // {
      # Enable GNOME
      displayManager.gdm = enabled;
      desktopManager.gnome = enabled;
    };

    # Copy and paste
    environment.systemPackages = with pkgs; [
      pkgs.xsel
    ];

    # SSH Agent
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    programs.ssh.startAgent = true;

    # Activate special dns config
    nichts.networking.dns = enabled;
  };
}
