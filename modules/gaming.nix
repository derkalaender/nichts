{
  flake.modules.nixos.gaming = {pkgs, ...}: {
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

    nixpkgs.overlays = [
      (final: prev: {
        inherit (prev.unstable) heroic;
      })
    ];

    environment.systemPackages = with pkgs; [
      mangohud
      heroic
      lutris
      prismlauncher # minecraft
    ];
  };
}
