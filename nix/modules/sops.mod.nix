{ inputs, ... }: {
  nichts.modules.sops.nixos = {
    imports = [
      inputs.sops-nix.nixosModules.default
    ];
  };

  nichts.modules.sops.home = {
    imports = [
      inputs.sops-nix.homeManagerModules.default
    ];
  };
}
