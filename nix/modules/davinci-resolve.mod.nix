{ nichts, ... }: {
  nichts.modules.home.davinci-resolve = { pkgs, ... }: {
    home.packages = [
      (pkgs.callPackage ../packages/davinci-resolve/davinci-patched.nix { })
    ];
  };
}
