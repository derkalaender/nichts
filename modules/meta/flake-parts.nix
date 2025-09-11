{inputs, ...}: {
  # Enables the use of flake.modules.{nixos,home-manager,...}.<name> pattern to declare reusable modules
  imports = [inputs.flake-parts.flakeModules.modules];
}
