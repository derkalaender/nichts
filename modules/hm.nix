{
  flake.modules.nixos.core = {
    inputs,
    system,
    host,
    lib,
    ...
  }: {
    home-manager = {
      extraSpecialArgs = {
        inherit inputs system host lib;
      };
    };
  };
}
