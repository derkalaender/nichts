{inputs, ...}: {
  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
  };

  nichts.aspects.core = {
    nixos.imports = [
      inputs.sops-nix.nixosModules.default
    ];

    homeManager.imports = [
      inputs.sops-nix.homeManagerModules.default
    ];
  };
}
