{ inputs, ... }: {
  nichts.modules.nixos.disko = {
    imports = [ inputs.disko.nixosModules.default ];
  };
}
