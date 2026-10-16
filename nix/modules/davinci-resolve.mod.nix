{ nichts, ... }: {
  nichts.modules.home.davinci-resolve = { pkgs, ... }: {
    home.packages = [
      pkgs.davinci-patched
    ];
  };
}
