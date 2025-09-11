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
        inherit inputs system host lib; # pass special args from NixOS to Home Manager
      };

      # Makes Home Manager use pkg from NixOS. This way, overlays, nixpkgs config, etc. carries over.
      useGlobalPkgs = true;
      # Install packages through NixOS user profiles instead of Home Manager script.
      useUserPackages = true;
      backupFileExtension = "bak";
    };
  };
}
