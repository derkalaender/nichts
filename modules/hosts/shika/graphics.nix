{
  flake.modules.nixos.host_shika = {pkgs, ...}: {
    hardware = {
      # AMD settings
      amdgpu = {
        initrd.enable = true;
        opencl.enable = true;
      };

      # Enable hardware video acceleration
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    # Use AMD GPU for video acceleration
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "radeonsi";
      VDPAU_DRIVER = "radeonsi";
    };

    # OC, fan curves, etc.
    services.lact.enable = true;

    # Packages to check status
    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
      clinfo
      vulkan-tools
      mesa-demos
    ];
  };
}
