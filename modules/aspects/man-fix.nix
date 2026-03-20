{
  # This is needed because fish forces man caches to be generated.
  # This slows down rebuilding dramatically.
  # TODO: Can be removed once we switch to nushell.
  # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365

  nichts.aspects.core = {
    nixos.documentation.man.cache.enable = false;
    homeManager.programs.man.generateCaches = false;

    # See https://github.com/nix-community/home-manager/issues/7935#issuecomment-3671184459
    manual.manpages.enable = false;
  };
}
