{inputs, ...}: {
  imports = with inputs; [
    flake-file.flakeModules.dendritic
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
}
