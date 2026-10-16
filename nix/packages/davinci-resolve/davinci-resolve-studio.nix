# Studio variant of the wrapped package.
{ pkgs }:
pkgs.davinci-resolve.override {
  davinci-resolve-unwrapped = pkgs.davinci-resolve-studio-unwrapped;
  studioVariant = true;
}
