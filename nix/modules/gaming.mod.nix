{
  # TODO: Lutris uses openldap for some strange reasons. Tests currently fail, we disable those.
  # See https://github.com/NixOS/nixpkgs/issues/513245
  nichts.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (old: {
        doCheck = !prev.stdenv.hostPlatform.isi686; # Only on i686, otherwise KDE will be recompiled
      });
    })
  ];

  nichts.modules.gaming.nixos = { pkgs, ... }: {
    # This allows games to activate system optimizations
    programs.gamemode.enable = true;

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      protontricks.enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    environment.systemPackages = with pkgs; [
      mangohud
      (heroic.override {
        extraPkgs =
          pkgs': with pkgs'; [
            gamescope
            gamemode
            mangohud
          ];
      })
      # lutris # gtk2 deprecated
      prismlauncher # minecraft
    ];
  };
}
