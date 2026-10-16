{nichts, ...}: {
  nichts.modules.home.nuvio = {pkgs, ...}: {
    home.packages = [
      pkgs.nuvio
    ];
  };
}
