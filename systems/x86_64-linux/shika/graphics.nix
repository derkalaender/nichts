{
  lib,
  config,
  pkgs,
  ...
}: {
  # Enable NVIDIA graphics for Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware = lib.mkMerge [
    {
      # NVIDIA settings
      nvidia = {
        # Required for increased compatibility
        modesetting.enable = true;
        # Experimental. Needed for proper suspend/resume
        powerManagement.enable = true;
        # Settings panel
        nvidiaSettings = true;
        # I have a GTX1060 which doesn't support the new open module parts
        open = false;
        # Use latest driver version. 565.77 as of now.
        package = config.boot.kernelPackages.nvidiaPackages.latest;
      };
    }

    {
      # Enable hardware video acceleration
      graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages = with pkgs; [
          # Intel
          intel-vaapi-driver
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
        ];

        extraPackages32 = with pkgs.driversi686Linux; [
          # Intel
          intel-vaapi-driver
          intel-media-driver
        ];
      };
    }
  ];

  # Environment variables so that programs can pick up on it
  # We want to use NVIDIA for both
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia"; # NVIDIA
    VDPAU_DRIVER = "nvidia"; # NVIDIA
  };

  # Packages to check status
  environment.systemPackages = with pkgs; [
    libva-utils
    vdpauinfo
  ];
}
