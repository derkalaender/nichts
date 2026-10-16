{
  nichts,
  ...
}:
{
  # Every host and user gets these. Members are individual units, so a new
  # always-on unit is added here and nowhere else.
  nichts.modules.default.nixos = {
    imports = with nichts.modules; [
      boot.nixos
      cli.nixos
      compat.nixos
      disko.nixos
      home-manager.nixos
      man-fix.nixos
      networking.nixos
      nix.nixos
      nixos-ng.nixos
      regional.nixos
      shell.nixos
      sops.nixos
      sudo.nixos
      users.nixos
    ];
  };

  nichts.modules.default.home = {
    imports = with nichts.modules; [
      cli.home
      home-manager.home
      man-fix.home
      shell.home
      sops.home
    ];
  };
}
