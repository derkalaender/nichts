{
  lib,
  osConfig,
  ...
}: {
  home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
}
