{
  # New options for NixOS that replace legacy scripts
  # Based on https://github.com/TheMaxMur/NixOS-Configuration/blob/master/system/nixos/modules/nixos-ng/default.nix

  nichts.aspects.core.nixos = {
    # services.userborn.enable = true; # Disable for now because it doesn't handle sub*ids yet (required for, e.g., podman). See https://github.com/nikstur/userborn/issues/7
    services.dbus.implementation = "broker";
  };
}
