{ lib, ... }:
with lib.nichts;
{
  wsl = enabled // {
    defaultUser = "marvin";
    wslConf = {
      automount.enabled = true;
    };
    interop.includePath = false;
  };
}
