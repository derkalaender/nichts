{lib, ...}:
with lib; {
  mkEnableOpt = name: {enable = mkEnableOption name;};

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };
}
