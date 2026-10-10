{inputs, ...}: {
  flake-file.inputs = {
    affinity-nix = {
      url = "github:mrshmllow/affinity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  nichts.overlays = [
    inputs.affinity-nix.overlays.default
  ];

  nichts.aspects.affinity = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        affinity-photo
        affinity-designer
      ];
    };
  };
}
