{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkDefault;
in {
  flake-file.inputs = {
    home-manager.url = "github:nix-community/home-manager";
  };

  nichts.aspects.core = {
    nixos = {
      imports = [inputs.home-manager.nixosModules.default];

      home-manager = {
        # Makes Home Manager use pkg from NixOS. This way, overlays, nixpkgs config, etc. carries over.
        useGlobalPkgs = true;
        # Install packages through NixOS user profiles instead of Home Manager script.
        useUserPackages = true;
        backupFileExtension = "bak";
      };
    };

    homeManager = {osConfig, ...}: {
      xdg.enable = true;

      home.stateVersion = mkDefault osConfig.system.stateVersion;
    };
  };
}
