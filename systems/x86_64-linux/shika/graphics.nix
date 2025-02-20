{
  lib,
  config,
  pkgs,
  ...
}: let
  # Use new beta 570.86.16 driver (see here for a list https://forums.developer.nvidia.com/t/current-graphics-driver-releases/28500)
  # To generate hashes: use lib.fakeSha256, run once and copy the hash from the error message
  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "570.86.16";
    sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
    openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
    settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
    usePersistenced = false; # we don't run in headless mode
  };
in {
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
        package = nvidiaDriver;
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

  # Load NVIDIA kernel module in early boot for prettier boot screen
  boot.initrd.kernelModules = ["nvidia"];
  boot.extraModulePackages = [nvidiaDriver];

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

  # Fix bug where gnome-shell is trying to talk to the NVIDIA driver after already having gone to suspend
  # https://bbs.archlinux.org/viewtopic.php?pid=2044189#p2044189
  systemd.services = {
    # Stop gnome-shell on suspend
    suspend-gnome-shell = {
      description = "Suspend gnome-shell";
      before = [
        "systemd-suspend.service"
        "systemd-hibernate.service"
        "nvidia-suspend.service"
        "nvidia-hibernate.service"
      ];
      wantedBy = [
        "systemd-suspend.service"
        "systemd-hibernate.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.procps}/bin/pkill -f -STOP gnome-shell";
      };
    };

    # Continue gnome-shell on resume
    resume-gnome-shell = {
      description = "Resume gnome-shell";
      after = [
        "systemd-suspend.service"
        "systemd-hibernate.service"
        "nvidia-resume.service"
      ];
      wantedBy = [
        "systemd-suspend.service"
        "systemd-hibernate.service"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.procps}/bin/pkill -f -CONT gnome-shell";
      };
    };
  };
}
