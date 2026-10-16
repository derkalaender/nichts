{ inputs, ... }: {
  nichts.overlays = [
    inputs.affinity-nix.overlays.default
  ];

  nichts.modules.home.affinity = { pkgs, ... }: {
    home.packages = with pkgs; [
      affinity-photo
      affinity-designer
    ];
  };
}
