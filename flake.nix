{
    description = "Nichts";

    inputs = {
        # Package repositories
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
        unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        # Opinionated flake layout
        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # User packages and configuration
        home-manager = {
            url = "github:nix-community/home-manager/release-23.11";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = inputs@{snowfall-lib, ...}:
        snowfall-lib.mkFlake {
            # Snowfall-specific
            inherit inputs;
            src = ./.;
            snowfall = {
                namespace = "nichts";
                meta = {
                    name = "nichts";
                    title = "Nichts";
                };
            };

            # NixPkgs config
            channels-config = {
                allowUnfree = true;
            };
        };
}
