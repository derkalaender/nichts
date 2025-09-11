{
  self,
  inputs,
  lib,
  ...
}: {
  flake.modules.nixos.core = {system, ...}: {
    # Legacy modules
    imports = let
      mymodules = [(inputs.import-tree "${self}/OLD/modules/nixos")];
      inputmodules = with inputs; [
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
        nix-index-database.nixosModules.nix-index
        xmc-nix.nixosModules.jlink
        determinate.nixosModules.default
        home-manager.nixosModules.home-manager
      ];
    in
      mymodules ++ inputmodules;

    # Legacy overlays
    nixpkgs.overlays = let
      channels = {
        nixpkgs = import inputs.nixpkgs {
          inherit system;
        };
        unstable = import inputs.unstable {
          inherit system;
        };
      };
      myoverlays =
        (inputs.import-tree.withLib lib).leafs "${self}/OLD/overlays"
        |> map (f: {inherit channels;} |> import f);
      inputoverlays = with inputs; [
        deploy-rs.overlays.default
        nix-alien.overlays.default
      ];
    in
      myoverlays ++ inputoverlays;
  };
}
