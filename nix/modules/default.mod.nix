{
  nichts,
  ...
}:
{
  # Every host and user gets these. Members are individual units, so a new
  # always-on unit is added here and nowhere else.
  nichts.modules.default.nixos = {
    imports = with nichts.lib.units.nixos; [
      boot
      cli
      compat
      disko
      home-manager
      man-fix
      networking
      nix
      nixos-ng
      regional
      shell
      sops
      sudo
      users
    ];
  };

  nichts.modules.default.home = {
    imports = with nichts.lib.units.home; [
      cli
      home-manager
      man-fix
      shell
      sops
    ];
  };
}
