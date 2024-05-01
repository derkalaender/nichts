{ lib, ... }:
with lib.nichts;
{
  wsl = enabled // {
    defaultUser = "marvin";
    nativeSystemd = true;
    wslConf = {
      automount.enabled = true;
    };
  };
}
