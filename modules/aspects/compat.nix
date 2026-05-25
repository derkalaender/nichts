{inputs, ...}: {
  # Allow running all kinds of non-nix software

  flake-file.inputs = {
    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-index-database.follows = "nix-index-database";
    };
  };

  nichts.overlays = [inputs.nix-alien.overlays.default];

  nichts.aspects.core.nixos = {pkgs, ...}: {
    programs.nix-ld = {
      enable = true;
      # Steam contains most necessary libraries. See https://wiki.nixos.org/wiki/FAQ#I've_downloaded_a_binary,_but_I_can't_run_it,_what_can_I_do?
      libraries = pkgs.steam-run.args.multiPkgs pkgs;
    };

    environment.systemPackages = [pkgs.nix-alien];
  };

  # Graphical environments get flatpaks as well
  nichts.aspects.desktop.nixos = {
    services.flatpak.enable = true;
  };
}
