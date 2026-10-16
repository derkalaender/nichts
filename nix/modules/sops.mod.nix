{inputs, ...}: {
  nichts.modules.nixos.sops = {
    imports = [
      inputs.sops-nix.nixosModules.default
    ];
  };

  nichts.modules.home.sops = {
    imports = [
      inputs.sops-nix.homeManagerModules.default
    ];
  };
}
