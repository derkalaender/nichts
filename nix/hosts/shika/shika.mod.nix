{
  config,
  nichts,
  ...
}:
{
  imports = [ ./disko.nix ];

  nichts.entities.hosts.shika = {
    users = [ "marvin" ];

    # Home Manager side of this host's units, for every user it lists.
    module.home = {
      imports = with nichts.modules; [
        desktop.home
        vr.home
      ];
    };

    module.nixos =
      {
        pkgs,
        lib,
        ...
      }:
      {
        imports = [
          ./sops.nix
          ./backup.nix
        ]
        ++ (with nichts.modules; [
          desktop.nixos
          gaming.nixos
          tailscale.nixos
          comfyui.nixos
          llama.nixos
          vr.nixos
          hardware-amdgpu.nixos
          hardware-unfree.nixos
          minecraft.nixos
          docker.nixos
          kubernetes-tools.nixos
          btrfs.nixos
        ]);

        # Disk configuration via disko
        inherit (config.flake.diskoConfigurations.shika) disko;

        # Additional hardware config via facter
        hardware.facter.reportPath = ./facter.json;

        programs.wireshark.enable = true;

        environment.systemPackages = with pkgs; [
          rquickshare
          colord
          mergerfs
        ];

        programs.fuse.userAllowOther = true;
        fileSystems."/archive" = {
          noCheck = lib.mkForce true; # Disable fsck on mergerfs
          depends = [
            "/mnt/archive1"
            "/mnt/archive2"
          ];
        };
        nichts.btrfs.fileSystems = [
          "/"
          "/projects"
          "/games"
          "/mnt/archive1"
          "/mnt/archive2"
        ];

        # Models directory with correct permissions and no CoW for better performance
        systemd.tmpfiles.rules = [
          "d /models 0755 marvin users -"
          "h /models - - - - +C"
        ];

        boot.tmp.useTmpfs = true;

        services.open-webui = {
          enable = false; # TODO: currently broken, see: https://github.com/NixOS/nixpkgs/issues/523304
        };

        # Brother Printer
        services.udev.extraRules = ''
          # Brother Printer
          SUBSYSTEM=="usb", ATTRS{idVendor}=="04f9", TAG+="uaccess"

          # GPUs
          # /dev/dri/igpu -> 7800X3D
          SUBSYSTEM=="drm", KERNEL=="card*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", KERNELS=="0000:10:00.0", SYMLINK+="dri/igpu"
          # /dev/dri/dgpu -> RX 9070 XT
          SUBSYSTEM=="drm", KERNEL=="card*", SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1002", KERNELS=="0000:03:00.0", SYMLINK+="dri/dgpu"
        '';

        # environment.sessionVariables = {
        #   # Prefer iGPU for Desktop
        #   KWIN_DRM_DEVICES = "/dev/dri/igpu:/dev/dri/dgpu";
        # };

        system.stateVersion = "25.11";
      };
  };
}
