{
  inputs,
  nichts,
  withSystem,
  ...
}: let
  inherit (inputs) nixos-generators;

  mkGenerator = name: system: format:
    nixos-generators.nixosGenerate {
      inherit format;
      pkgs = withSystem system ({pkgs, ...}: pkgs);
      modules = with nichts.aspects; [
        (core.resolve {class = "nixos";})
        (generators._.${name}.resolve {class = "nixos";})
      ];
    };
in {
  flake-file.inputs = {
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.generators.install-iso = mkGenerator "install-iso" "x86_64-linux" "install-iso";
}
