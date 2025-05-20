{
  description = "Nichts";

  inputs = {
    # Package repositories
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Opinionated flake layout
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User packages and configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
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

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secure Boot
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager autostart
    xdg-autostart = {
      url = "github:Zocker1999NET/home-manager-xdg-autostart";
    };

    # Automatic database updates for nix-index
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # XMC on nixos
    xmc-nix.url = "github:derkalaender/xmc-nix";
    xmc-nix.inputs.nixpkgs.follows = "nixpkgs";

    # ISO generation
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware configuration
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    # Remote deployment
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    snowfall-lib,
    ...
  }:
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
        inputs.deploy-rs.overlays.default
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
        disko.nixosModules.disko
        lanzaboote.nixosModules.lanzaboote
        nix-index-database.nixosModules.nix-index
        xmc-nix.nixosModules.jlink
      ];

      # Additional home modules
      homes.modules = with inputs; [
        spicetify-nix.homeManagerModules.default
        sops-nix.homeManagerModules.sops
        xdg-autostart.homeManagerModules.xdg-autostart
      ];

      # deploy-rs configuration
      deploy = {
        sshUser = "otta"; # Will use this to SSH into the host
        activationTimeout = 60 * 5; # 5 minutes
        confirmTimeout = 60;

        nodes = let
          mkSystemPath = config: (inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${config});
        in {
          kawauso = {
            hostname = "192.168.178.55";
            profiles.system.path = mkSystemPath "kawauso";
          };
        };
      };

      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) inputs.deploy-rs.lib;
    };
}
