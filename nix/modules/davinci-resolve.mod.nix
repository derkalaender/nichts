{ nichts, ... }: {
  nichts.modules.davinci-resolve.home = { pkgs, ... }: {
    home.packages = [
      pkgs.davinci-patched
    ];
  };
}
