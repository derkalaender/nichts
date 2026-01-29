{
  inputs,
  nichts,
  withSystem,
  ...
}: let
  inherit (inputs) nixpkgs;

  # Create a new NixOS host with the given name and system architecture (e.g., "x86_64-linux")
  # An aspect nichts.aspects.${name} must exist.
  mkHost = name: system:
    nixpkgs.lib.nixosSystem {
      modules = with nichts.aspects; [
        (core.resolve {class = "nixos";})
        (hosts._.${name}.resolve {class = "nixos";})
        # Use pkgs from flake-parts
        nixpkgs.nixosModules.readOnlyPkgs
        {nixpkgs.pkgs = withSystem system ({pkgs, ...}: pkgs);}
      ];
    };
in {
  flake.nixosConfigurations.shika = mkHost "shika" "x86_64-linux";
}
