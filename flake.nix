{
    description = "My innocent NixOS configuration";

    # Dependencies
    inputs = {
        # Main package repository pinned to the current NixOS version for best stability
        nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # todo change this back?
        # Some bleeding-edge packages are required
        unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

        # Configuration of home dirs
        home-manager = {
            url = "github:nix-community/home-manager/release-23.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    # Output configurations
    outputs = inputs@{ self, nixpkgs, home-manager, ... }: {

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
                    system = "x86_64-linux";
                    modules = [
                        # Import machine specific configuration
                        (./machines + "/${x}/configuration.nix")
                        # Make modules available to NixOS configuration
                        { imports = builtins.attrValues self.nixosModules; }
                        # Home Manager
                        home-manager.nixosModules.home-manager
                    ];
                };
            })
            (builtins.attrNames (builtins.readDir ./machines))
        );
    };
}