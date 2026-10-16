{
  config,
  inputs,
  lib,
  nichts,
  withSystem,
  ...
}:
{
  options.flake.generators = lib.mkOption {
    description = "System images, built with nixos-generators.";
    type = with lib.types; lazyAttrsOf raw;
    default = { };
  };

  config.flake.generators.install-iso = inputs.nixos-generators.nixosGenerate {
    format = "install-iso";
    pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
    modules = [
      nichts.modules.default.nixos
      nichts.modules.install-iso.nixos
    ];
  };
}
