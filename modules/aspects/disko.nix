{inputs, ...}: {
  imports = [inputs.disko.flakeModule];

  flake-file.inputs = {
    disko.url = "github:nix-community/disko";
  };

  nichts.aspects.core.nixos = {
    imports = [inputs.disko.nixosModules.default];
  };
}
