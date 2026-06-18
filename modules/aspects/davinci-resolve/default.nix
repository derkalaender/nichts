{
  lib,
  withSystem,
  ...
}: let
  inherit (lib) singleton;
in {
  perSystem = {pkgs, ...}: {
    packages = {
      davinci-resolve-unwrapped = pkgs.callPackage ./_pkgs/davinci-resolve-unwrapped.nix {};
      davinci-resolve = pkgs.callPackage ./_pkgs/davinci-resolve.nix {
        inherit (pkgs) davinci-resolve-unwrapped;
      };
      davinci-resolve-studio-unwrapped = pkgs.davinci-resolve-unwrapped.override {
        studioVariant = true;
      };
      davinci-resolve-studio = pkgs.davinci-resolve.override {
        davinci-resolve-unwrapped = pkgs.davinci-resolve-studio-unwrapped;
        studioVariant = true;
      };

      ffmpeg-encoder-plugin = pkgs.callPackage ./_pkgs/ffmpeg-encoder-plugin.nix {};
      aac-encoder-plugin = pkgs.callPackage ./_pkgs/aac-encoder-plugin.nix {};
      aac-fdk-encoder-plugin = pkgs.callPackage ./_pkgs/aac-fdk-encoder-plugin.nix {};
    };
  };

  nichts.overlays = singleton (final: prev: (
    withSystem prev.stdenv.hostPlatform.system ({config, ...}: {
      inherit (config.packages) davinci-resolve-unwrapped davinci-resolve;
      inherit (config.packages) davinci-resolve-studio-unwrapped davinci-resolve-studio;
      inherit (config.packages) ffmpeg-encoder-plugin aac-encoder-plugin aac-fdk-encoder-plugin;
    })
  ));

  nichts.aspects.davinci-resolve = {
    homeManager = {pkgs, ...}: {
      home.packages = [
        (pkgs.callPackage ./_pkgs/davinci-patched.nix {})
      ];
    };
  };
}
