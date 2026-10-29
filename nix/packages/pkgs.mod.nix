{
  inputs,
  lib,
  ...
}:
let
  packages = system: pkgs: {
    aac-encoder-plugin = pkgs.callPackage ./davinci-resolve/aac-encoder-plugin.nix { };
    aac-fdk-encoder-plugin = pkgs.callPackage ./davinci-resolve/aac-fdk-encoder-plugin.nix { };
    ffmpeg-encoder-plugin = pkgs.callPackage ./davinci-resolve/ffmpeg-encoder-plugin.nix { };

    davinci-resolve-unwrapped = pkgs.callPackage ./davinci-resolve/davinci-resolve-unwrapped.nix { };
    davinci-resolve = pkgs.callPackage ./davinci-resolve/davinci-resolve.nix { };
    davinci-resolve-studio-unwrapped = pkgs.davinci-resolve-unwrapped.override {
      studioVariant = true;
    };
    davinci-resolve-studio = pkgs.davinci-resolve.override {
      davinci-resolve-unwrapped = pkgs.davinci-resolve-studio-unwrapped;
      studioVariant = true;
    };
    davinci-patched = pkgs.callPackage ./davinci-resolve/davinci-patched.nix { };

    nuvio = pkgs.callPackage ./nuvio.nix { };
  };
in
{
  # Add all our custom packages as an overlay.
  nichts.overlays = [
    (final: prev: packages prev.stdenv.hostPlatform.system final)
  ];

  perSystem = { pkgs, system, ... }: {
    # The same packages, as flake outputs, from the overlaid pkgs.
    packages = lib.getAttrs (builtins.attrNames (packages system pkgs)) pkgs;
  };
}
