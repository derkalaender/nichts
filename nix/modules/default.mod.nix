{
  nichts,
  ...
}:
{
  # Every host and user gets these. Members are individual units, so a new
  # always-on unit is added here and nowhere else.
  nichts.modules.nixos.default = {
    imports = with nichts.modules.nixos; [
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

  nichts.modules.home.default = {
    imports = with nichts.modules.home; [
      cli
      home-manager
      man-fix
      shell
      sops
    ];
  };
}
