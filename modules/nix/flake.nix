let
  caches = [
    {
      url = "https://install.determinate.systems";
      keys = [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
        "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
        "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
        "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
        "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
        "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
        "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
      ];
    }
  ];

  extra-substituters = map (cache: cache.url) caches;
  extra-trusted-public-keys = builtins.concatMap (cache: cache.keys) caches;
in {
  flake-file.formatter = pkgs: pkgs.nixfmt;

  flake-file.nixConfig = {
    inherit extra-substituters extra-trusted-public-keys;

    # Enable Flakes and new nix cmd
    experimental-features = ["nix-command" "flakes" "pipe-operators"];
    # Give anyone with root access special permissions when talking to the Nix daemon
    trusted-users = ["root" "@wheel"];

    # Don't pollute home with nix files
    use-xdg-base-directories = true;

    # Better error messages
    warn-dirty = false;
    show-trace = true;

    # Improve performance
    http-connections = 50;
    max-jobs = "auto";
    max-substitution-jobs = 32;

    # Don't remove any dependencies needed to build alive (non-GC'd) packages
    keep-outputs = true;
    keep-derivations = true;

    # Saves disk space
    auto-optimise-store = true;

    # Don't hang forever on unreliable binary caches
    connect-timeout = 5;

    # https://determinate.systems/posts/changelog-determinate-nix-352/
    lazy-trees = true;
    # https://docs.determinate.systems/determinate-nix/#parallel-evaluation
    eval-cores = 0;
  };
}
