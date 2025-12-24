{
  # New options for NixOS that replace legacy scripts
  # Based on https://github.com/TheMaxMur/NixOS-Configuration/blob/master/system/nixos/modules/nixos-ng/default.nix

  flake.modules.nixos.core = {
    services.userborn.enable = true;
    services.dbus.implementation = "broker";
  };
}
