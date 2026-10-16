{ inputs, ... }: {
  nichts.modules.disko.nixos = {
    imports = [ inputs.disko.nixosModules.default ];
  };
}
