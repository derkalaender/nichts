{ inputs, ... }: {
  nichts.overlays = [
    inputs.affinity-nix.overlays.default
  ];

  nichts.modules.affinity.home = { pkgs, ... }: {
    home.packages = with pkgs; [
      affinity-photo
      affinity-designer
    ];
  };
}
