{inputs, ...}: {
  imports = with inputs; [
    flake-file.flakeModules.dendritic
    flake-file.flakeModules.nix-auto-follow
  ];
}
