{ nichts, ... }: {
  nichts.modules.nuvio.home = { pkgs, ... }: {
    home.packages = [
      pkgs.nuvio
    ];
  };
}
