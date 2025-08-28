{
  # New options for NixOS that replace legacy scripts
  # Based on https://github.com/TheMaxMur/NixOS-Configuration/blob/master/system/nixos/modules/nixos-ng/default.nix

  system.switch.enableNg = true;
  services.userborn.enable = true;
  services.dbus.implementation = "broker";

  # This is still very experimental and stuff could break, so we leave it disabled for now
  # boot.initrd.systemd.enable = true;
  # system.etc.overlay.enable = true;
  # system.etc.overlay.mutable = false;
}
