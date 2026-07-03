{
  config,
  nichts,
  ...
}: {
  nichts.aspects.hosts._.shika = {
    includes = with nichts.aspects; [
      hosts._.shika._.users
      hardware._.amdgpu
      hardware._.unfree
      desktop
      gaming
      tailscale
      comfyui
      llama
    ];

    nixos = {pkgs, ...}: {
      # Disk configuration via disko
      inherit (config.flake.diskoConfigurations.shika) disko;

      # Additional hardware config via facter
      hardware.facter.reportPath = ./facter.json;

      # Set network hostname to host configuration name
      networking.hostName = "shika";

      virtualisation = {
        docker = {
          enable = true;
        };
      };

      programs.wireshark.enable = true;

      # Minecraft
      networking.firewall.allowedTCPPorts = [25565];
      networking.firewall.allowedUDPPorts = [25565];

      environment.systemPackages = with pkgs; [
        kubectl
        k9s
        kubernetes-helm
        kustomize
        kind
        minikube
        kn
        fluxcd
        telepresence2
        sshfs # needed by telepresence2
        cloudflared
        docker-credential-helpers
        docker-compose
        rquickshare
        colord
      ];

      programs.fuse.userAllowOther = true;

      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = ["/"];
      };

      # Games and models directory with correct permissions and no CoW for better performance
      systemd.tmpfiles.rules = [
        "d /games 0755 marvin users -"
        "h /games - - - - +C"

        "d /models 0755 marvin users -"
        "h /models - - - - +C"
      ];

      boot.tmp.useTmpfs = true;

      # Sysctl config for btrfs drive from CachyOS https://github.com/CachyOS/CachyOS-Settings/blob/9c623471493d8faa22614ee5eecbd59a6d028b53/usr/lib/sysctl.d/70-cachyos-settings.conf
      boot.kernel.sysctl = {
        "vm.dirty_bytes" = 256 * 1024 * 1024; # 256MiB, means more flushes so it doesn't stall on large writes (default 10% of RAM, so 6.4GiB)
        "vm.dirty_background_bytes" = 64 * 1024 * 1024; # 64MiB, same as above but for kernel background flusher
        "vm.dirty_expire_centisecs" = 15 * 1000; # 15s, higher than default 5s means flushes will be batched together more if we don't exceed the above limits
        "vm.vfs_cache_pressure" = 50; # default is 100, lower means the kernel will prefer to keep file data in RAM which is good on btrfs where metadata can be large
      };

      services.open-webui = {
        enable = false; # TODO: currently broken, see: https://github.com/NixOS/nixpkgs/issues/523304
      };

      # Brother Printer
      services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="04f9", TAG+="uaccess"
      '';

      system.stateVersion = "25.11";
    };
  };
}
