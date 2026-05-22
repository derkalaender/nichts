{
  lib,
  inputs,
  ...
}: let
  inherit (lib) singleton;
in {
  flake-file.inputs = {
    affinity-nix.url = "github:mrshmllow/affinity-nix";
  };

  nichts.overlays = singleton inputs.affinity-nix.overlays.default;

  nichts.aspects.affinity = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        affinity-photo
        affinity-designer
      ];
    };
  };
}
