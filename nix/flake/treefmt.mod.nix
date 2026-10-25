{ inputs, ... }: {
  imports = [ inputs.treefmt-nix.flakeModule ];

  # `nix fmt` and `nix flake check` now go through treefmt with nixfmt.
  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
    };
  };
}
