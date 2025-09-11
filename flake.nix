{
  description = "Nichts";

  nixConfig = {
    extra-substituters = [
      "https://install.determinate.systems"
    ];

    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];

    # Enable Flakes and new nix cmd
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    # Give anyone with root access special permissions when talking to the Nix daemon
    trusted-users = ["root" "@wheel"];

    warn-dirty = false;
    show-trace = true;
    http-connections = 50;
    max-jobs = "auto";
    max-substitution-jobs = 32;

    # https://determinate.systems/posts/changelog-determinate-nix-352/
    lazy-trees = true;
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    systems.url = "github:nix-systems/default";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "dedupe_flake-compat";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "dedupe_flake-compat";
    };

    xdg-autostart = {
      url = "github:Zocker1999NET/home-manager-xdg-autostart";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xmc-nix = {
      url = "github:derkalaender/xmc-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "dedupe_flake-utils";
      inputs.systems.follows = "systems";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "dedupe_flake-compat";
      inputs.utils.follows = "dedupe_flake-utils";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-index-database.follows = "nix-index-database";
      inputs.flake-compat.follows = "dedupe_flake-compat";
    };
  };

  # Additional inputs for flake.lock dedupe
  inputs = {
    dedupe_flake-compat.url = "github:edolstra/flake-compat";
    dedupe_flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    import-tree,
    ...
  }: let
    # Extend nixpkgs.lib with custom lib and Home Manager lib
    # Home Manager lib is required because it expects certain functions under lib.hm
    # Exposing this everywhere seems to be the simplest solution
    # Adapted from https://github.com/bangedorrunt/nix/blob/f5a8a5d2f023f7d6558b0ce7051ff5e258860f55/flake.nix#L60-L78
    lib = nixpkgs.lib.extend (final: prev:
      (import ./lib {
        lib = final;
        inherit self;
      })
      // home-manager.lib);
  in
    # See https://github.com/vic/import-tree/blob/6ebb8cb87987b20264c09296166543fd3761d274/README.md?plain=1#L9-L17
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit lib;};
    } (import-tree ./modules);
}
