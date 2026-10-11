{inputs, ...}: {
  # Oculus Rift CV1 (original, 2016) support.
  #
  # The runtime is upstream Monado built with OpenHMD's Rift CV1 driver, taken
  # from derkalaender/monado-cv1-nixos. Upstream nixpkgs Monado cannot drive
  # this headset: its rift driver is DK2-only (2833:0021/2021) and its
  # constellation tracker never advertises position tracking. That flake swaps
  # the driver for OpenHMD's rift-room-config branch, which tracks the HMD and
  # both Touch controllers.
  flake-file.inputs.monado-cv1-nixos = {
    url = "github:derkalaender/monado-cv1-nixos";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
  };

  nichts.aspects.vr.nixos = {pkgs, ...}: {
    services.monado = {
      enable = true;
      package = inputs.monado-cv1-nixos.packages.${pkgs.stdenv.hostPlatform.system}.monado;
      # /etc/xdg/openxr/1/active_runtime.json
      defaultRuntime = true;
      highPriority = true;
    };

    # 70-xrhardware.rules: uaccess for 2833:0031 (headset HID) and 2833:0211
    # (the two constellation cameras)
    services.udev.packages = [pkgs.xr-hardware];

    # Two UVC sensor streams are isochronous; the 16 MiB default is too small.
    boot.kernelParams = ["usbcore.usbfs_memory_mb=1000"];

    # Steam needs to be allowed to access Monado. See: https://vronlinux.org/docs/distros/nixos/
    programs.steam.package = pkgs.steam.override {
      extraProfile = ''
        # Allows Monado to be used
        export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
        # Fixes timezones on VRChat
        unset TZ
      '';
    };

    systemd.user.services.monado.environment = {
      # Exit when no client is connected, so the headset's panel and LED do not
      # stay on all day (the proximity sensor is not implemented in the
      # driver). monado.socket starts the runtime again on the next client.
      IPC_EXIT_WHEN_IDLE = "1";
      IPC_EXIT_WHEN_IDLE_DELAY_MS = "30000";
    };

    environment.systemPackages = with pkgs; [
      wayvr
      xrgears
      v4l-utils
      usbutils
    ];
  };

  # User-level wiring for OpenVR games.
  nichts.aspects.vr.homeManager = {
    pkgs,
    config,
    ...
  }: {
    # OpenVR games resolve their runtime through this file. xrizer bridges
    # OpenVR to OpenXR/Monado, so SteamVR is not needed (and SteamVR would
    # fight Monado for the headset's display lease). Written as a read-only
    # store file on purpose: Steam rewrites it on every start when it is
    # writable, putting SteamVR back first and silently breaking the chain.
    xdg.configFile."openvr/openvrpaths.vrpath".text = builtins.toJSON {
      jsonid = "vrpathreg";
      version = 1;
      runtime = ["${pkgs.xrizer}/lib/xrizer"];
      config = ["${config.home.homeDirectory}/.local/share/Steam/config"];
      log = ["${config.home.homeDirectory}/.local/share/Steam/logs"];
      external_drivers = null;
    };
  };
}
