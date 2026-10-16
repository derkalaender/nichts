# Studio variant of the unwrapped package: same sources, studio build.
{ pkgs }: pkgs.davinci-resolve-unwrapped.override { studioVariant = true; }
