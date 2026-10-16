{
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  nichts.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.default ];

    home-manager = {
      # Makes Home Manager use pkg from NixOS. This way, overlays, nixpkgs config, etc. carries over.
      useGlobalPkgs = true;
      # Install packages through NixOS user profiles instead of Home Manager script.
      useUserPackages = true;
      backupFileExtension = "bak";
    };
  };

  nichts.modules.home.home-manager = { osConfig, ... }: {
    xdg.enable = true;

    home.stateVersion = mkDefault osConfig.system.stateVersion;
  };
}
