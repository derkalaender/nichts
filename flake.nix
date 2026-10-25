{
  nixConfig = {
    substituters = [
      "https://cache.nixos.org?priority=1"
      "https://cache.numtide.com?priority=2"
      "https://nix-community.cachix.org?priority=3"
      "https://comfyui.cachix.org?priority=4"
      "https://cache.forall.systems?priority=5"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "comfyui.cachix.org-1:33mf9VzoIjzVbp0zwj+fT51HG0y31ZTK3nzYZAX0rec="
      "cache.forall.systems:5PmD7QO4MSF8YgyRZtkSGXRDo96H3bybIf2SsQh8ScI="
    ];
    # Empty on purpose: everything goes through `substituters` and
    # `trusted-public-keys` above, where the priorities live. nixpkgs' nix module
    # appends its own defaults to the `extra-` lists.
    extra-substituters = [ ];
    extra-trusted-public-keys = [ ];

    # Enable Flakes and new nix cmd
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operator"
    ];
    # Give anyone with root access special permissions when talking to the Nix daemon
    trusted-users = [
      "root"
      "@wheel"
    ];

    # Don't pollute home with nix files
    use-xdg-base-directories = true;

    # Better error messages
    warn-dirty = false;
    show-trace = true;

    # Improve performance
    http-connections = 50;
    max-jobs = "auto";
    # Default is 16; matches max-jobs = "auto" on this 16-core box. Substitution
    # is bandwidth-bound, and pushing this higher risks throttling on the Cachix
    # caches.
    max-substitution-jobs = 16;

    # Don't remove any dependencies needed to build alive (non-GC'd) packages
    keep-outputs = true;
    keep-derivations = true;

    # ~~Saves disk space~~ Not needed on btrfs and hitting hard link limits.
    auto-optimise-store = false;

    # Don't hang forever on unreliable binary caches
    connect-timeout = 5;
  };

  inputs = {
    affinity-nix = {
      url = "github:mrshmllow/affinity-nix";
      inputs = {
        flake-parts.follows = "flake-parts";
      };
    };
    comfyui-nix = {
      url = "github:utensils/comfyui-nix";
      inputs.flake-parts.follows = "flake-parts";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    monado-cv1-nixos = {
      url = "github:derkalaender/monado-cv1-nixos";
      inputs = {
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs = {
        nix-index-database.follows = "nix-index-database";
        nixpkgs.follows = "nixpkgs";
      };
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  # Every *.mod.nix file under ./nix is a flake-parts module.
  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }: {
        imports = builtins.filter (lib.hasSuffix ".mod.nix") (lib.filesystem.listFilesRecursive ./nix);
      }
    );
}
