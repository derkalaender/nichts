{
  # This is needed because fish forces man caches to be generated.
  # This slows down rebuilding dramatically.
  # TODO: Can be removed once we switch to nushell.
  # https://discourse.nixos.org/t/slow-build-at-building-man-cache/52365

  nichts.modules.nixos.man-fix = {
    documentation.man.cache.enable = false;
  };

  nichts.modules.home.man-fix = {
    programs.man.generateCaches = false;

  };
}
