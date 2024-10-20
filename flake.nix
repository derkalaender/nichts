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

        # Secret management
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # NixOS WSL support
        nixos-wsl = {
            url = "github:nix-community/NixOS-WSL";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Common hardware configuration
        nixos-hardware.url = "github:NixOS/nixos-hardware/master";

        # Modded Spotify
        spicetify-nix = {
            url = "github:Gerg-L/spicetify-nix";
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

            # Extra modules for shika, mostly hardware config
            systems.hosts.shika.modules = with inputs; [
                nixos-hardware.nixosModules.common-pc
                nixos-hardware.nixosModules.common-pc-ssd
                nixos-hardware.nixosModules.common-cpu-intel
                nixos-hardware.nixosModules.common-gpu-intel
                nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
            ];

            # Additional modules for every host
            systems.modules.nixos = with inputs; [
                sops-nix.nixosModules.sops
            ];

            # Additional home modules
            homes.modules = with inputs; [
                spicetify-nix.homeManagerModules.default
                sops-nix.homeManagerModules.sops
            ];
        };
}
