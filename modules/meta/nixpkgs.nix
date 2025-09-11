{
  flake.modules.nixos.core = {
    inputs,
    system,
    lib,
    ...
  }: {
    # Allows to install proprietary software
    nixpkgs.config.allowUnfree = true;

    # Make unstable packages available
    nixpkgs.overlays = let
      unstable = import inputs.unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
      # Needs to be ordered first so that other overlays can access unstable inside of prev.
      lib.mkBefore [
        (final: prev: {
          inherit unstable;
        })
      ];
  };
}
