{lib, ...}:
with lib.nichts; {
  wsl =
    enabled
    // {
      defaultUser = "marvin";
      wslConf = {
        automount.enabled = true;
      };
      interop.includePath = false;
      usbip = {
        enable = true;
        autoAttach = ["1-2" "2-2"];
        snippetIpAddress = "localhost";
      };
    };
}
