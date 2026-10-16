{
  inputs,
  withSystem,
  ...
}:
{
  nichts.modules.home.spotify = { pkgs, ... }: {
    imports = [ inputs.spicetify-nix.homeManagerModules.default ];

    programs.spicetify =
      let
        system = pkgs.stdenv.hostPlatform.system;
        spicePkgs = withSystem system ({ inputs', ... }: inputs'.spicetify-nix.legacyPackages);
      in
      {
        enable = true;
        wayland = false; # BUG: ugly titlebar
        enabledExtensions = with spicePkgs.extensions; [
          shuffle # better shuffle algorithm
          songStats # song statistics like dancability, tempo and key
          showQueueDuration # show the duration of the queue
        ];
        enabledCustomApps = with spicePkgs.apps; [
          lyricsPlus # better lyrics
        ];
        theme = spicePkgs.themes.catppuccin;
        colorScheme = "mocha";
      };
  };
}
