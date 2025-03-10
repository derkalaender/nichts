{
  lib,
  config,
  pkgs,
  ...
}: let
in {
  # Enable NVIDIA graphics for Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Enable cuda support in packages which need it
  nixpkgs.config.cudaSupport = true;

  hardware = {
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
      # Use new beta 570.86.16 driver (see here for a list https://forums.developer.nvidia.com/t/current-graphics-driver-releases/28500)
      # To generate hashes: use lib.fakeSha256, run once and copy the hash from the error message
      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
        version = "570.86.16";
        sha256_64bit = "sha256-RWPqS7ZUJH9JEAWlfHLGdqrNlavhaR1xMyzs8lJhy9U=";
        openSha256 = "sha256-DuVNA63+pJ8IB7Tw2gM4HbwlOh1bcDg2AN2mbEU9VPE=";
        settingsSha256 = "sha256-9rtqh64TyhDF5fFAYiWl3oDHzKJqyOW3abpcf2iNRT8=";
        usePersistenced = false; # we don't run in headless mode
      };
    };

    # Enable hardware video acceleration
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Enable NVIDIA in containers
    nvidia-container-toolkit.enable = true;
  };

  # Load NVIDIA kernel module in early boot for prettier boot screen
  boot = {
    initrd.kernelModules = ["nvidia"]; # Load NVIDIA kernel module in early boot to prevent flickering
    blacklistedKernelModules = ["nouveau" "i915"]; # Disable slow open source driver and iGPU

    kernelParams = lib.mkMerge [
      [
        "module_blacklist=i915" # Disable iGPU completely to prevent conflicts
        "nvidia.NVreg_UsePageAttributeTable=1" # Better for performance
      ]
      (lib.mkIf config.hardware.nvidia.powerManagement.enable [
        "nvidia.NVreg_TemporaryFilePath=/var/tmp" # Store suspend state on disk, not /tmp which is on RAM
      ])
    ];
  };

  # Environment variables so that programs can pick up on it
  # We want to use NVIDIA for both
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia"; # NVIDIA
    VDPAU_DRIVER = "nvidia"; # NVIDIA
    # "__EGL_VENDOR_LIBRARY_FILENAMES" = "${config.hardware.nvidia.package}/share/glvnd/egl_vendor.d/10_nvidia.json"; # see https://github.com/NixOS/nixpkgs/issues/372135
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
