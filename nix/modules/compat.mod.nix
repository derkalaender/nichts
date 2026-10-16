{ inputs, ... }: {
  # Allow running all kinds of non-nix software

  nichts.overlays = [ inputs.nix-alien.overlays.default ];

  nichts.modules.nixos.compat = { pkgs, ... }: {
    programs.nix-ld = {
      enable = true;
      # Steam contains most necessary libraries. See https://wiki.nixos.org/wiki/FAQ#I've_downloaded_a_binary,_but_I_can't_run_it,_what_can_I_do?
      libraries = pkgs.steam-run.args.multiPkgs pkgs;
    };

    environment.systemPackages = [ pkgs.nix-alien ];
  };

  # Graphical environments get flatpaks as well
  nichts.modules.nixos.desktop-compat = {
    services.flatpak.enable = true;
  };
}
