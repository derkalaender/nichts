{inputs, ...}: {
  imports = with inputs; [
    flake-file.flakeModules.dendritic
    # flake-file.flakeModules.nix-auto-follow # this is completely buggy right now and messes with flake check
  ];

  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
}
