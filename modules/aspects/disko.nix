{inputs, ...}: {
  imports = [inputs.disko.flakeModule];

  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nichts.aspects.core.nixos = {
    imports = [inputs.disko.nixosModules.default];
  };
}
