{
    description = "My innocent NixOS configuration";

    # Dependencies
    inputs = {
        # Main package repository pinned to the current NixOS version for best stability
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
        # Some bleeding-edge packages are required
        unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

        # Configuration of home dirs
        home-manager = {
            url = "github:nix-community/home-manager/release-23.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    # Output configurations
    outputs = inputs@{ self, nixpkgs, ... }: {

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
                    ];
                };
            })
            (builtins.attrNames (builtins.readDir ./machines))
        );
        # nixosConfigurations = {
        #     # Default
        #     nixos = nixpkgs.lib.nixosSystem {
        #         system = "x86_64-linux";
        #         modules = [
        #             # Import old configuration
        #             ./configuration.nix
        #         ];
        #     };
        # };
    };
}