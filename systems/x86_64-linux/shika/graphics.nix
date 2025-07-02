{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
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
      # Use new beta 575.57.08 driver (see here for a list https://forums.developer.nvidia.com/t/current-graphics-driver-releases/28500)
      # To generate hashes: use lib.fakeSha256, run once and copy the hash from the error message.
      # Make sure to change the hash every time you change the version, otherwise it will still think the old version is wanted.
      # TODO (temporary on 25.05 with Linux Kernel 6.15.x): add patch to make this build. See https://github.com/NixOS/nixpkgs/issues/412299#issuecomment-2955980698 and https://github.com/NixOS/nixpkgs/pull/412157
      package = let
        gpl_symbols_linux_615_patch = pkgs.fetchpatch {
          url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
          hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
          stripLen = 1;
          extraPrefix = "kernel/";
        };
      in
        config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "575.57.08";
          sha256_64bit = "sha256-KqcB2sGAp7IKbleMzNkB3tjUTlfWBYDwj50o3R//xvI=";
          openSha256 = "sha256-DOJw73sjhQoy+5R0GHGnUddE6xaXb/z/Ihq3BKBf+lg=";
          settingsSha256 = "sha256-AIeeDXFEo9VEKCgXnY3QvrW5iWZeIVg4LBCeRtMs5Io=";
          usePersistenced = false; # we don't run in headless mode

          patches = [gpl_symbols_linux_615_patch];
        };
    };

    # Enable hardware video acceleration
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Enable NVIDIA in containers
    nvidia-container-toolkit = {
      enable = true;
      package = pkgs.unstable.nvidia-container-toolkit;
    };
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
  systemd.services = let
    desktop = config.nichts.desktop;
  in
    mkIf (desktop.enable && desktop.flavor == "gnome") {
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
