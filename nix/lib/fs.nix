{ self }: rec {
  # Path into this flake's source tree, as a string.
  #
  # Prefer a plain relative path (`./foo`): a path is copied into the store
  # content-addressed, while a string built from `self` drags the *whole* source
  # tree in as a build dependency, which makes every commit rebuild things.
  # This exists for the rare case where a string really is required.
  get-file = p: "${self}/${p}";
}
