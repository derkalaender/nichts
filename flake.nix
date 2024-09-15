{
    description = "Nichts";

    inputs = {
        # Package repositories
        nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
        unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        # Opinionated flake layout
        snowfall-lib = {
            url = "github:snowfallorg/lib";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # User packages and configuration
        home-manager = {
            url = "github:nix-community/home-manager/release-24.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixos-wsl = {
            url = "github:nix-community/NixOS-WSL";
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

            # External overlays
            overlays = with inputs; [
                #
            ];

            # Itachi is the WSL-based host, so it needs the corresponding module
            systems.hosts.itachi.modules = with inputs; [
                nixos-wsl.nixosModules.default
            ];
        };
}
