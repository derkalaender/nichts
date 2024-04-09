{
    description = "Nichts zu sehen hier";

    # Dependencies
    inputs = {
        # Main package repository
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        # Configuration of home dirs
        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    # Output configurations
    outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
        let
            system = "x86_64-linux";
            unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
            };
        in
    {

        # Add modules from ./modules
        # Each subdir in ./modules should have a default.nix
        nixosModules = builtins.listToAttrs (map
            (x: {
                name = x;
                value = import (./modules + "/${x}");
            })
            (builtins.attrNames (builtins.readDir ./modules))
        );

        # Machines
        # Each subdir in ./machines is a system.
        # All systems need a configuration.nix
        nixosConfigurations = builtins.listToAttrs (map
            (x: {
                name = x;
                value = nixpkgs.lib.nixosSystem {
                    inherit system;
                    modules = [
                        # Import machine specific configuration
                        (./machines + "/${x}/configuration.nix")
                        # Make modules available to NixOS configuration
                        { imports = builtins.attrValues self.nixosModules; }
                        # Home Manager
                        home-manager.nixosModules.home-manager
                        # Module that adds "unstable" packages via `pkgs.unstable.x` syntax
                        {
                            nixpkgs.overlays = [
                            (final: prev: {
                                inherit unstable;
                            })
                        ];}
                    ];
                };
            })
            (builtins.attrNames (builtins.readDir ./machines))
        );
    };
}
