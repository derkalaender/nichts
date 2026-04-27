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
        cloudflared
        docker-credential-helpers
        docker-compose
        rquickshare
      ];

      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
      };

      # Games directory with correct permissions and no CoW for better performance
      systemd.tmpfiles.rules = [
        "d /games 0755 marvin users -"
        "h /games - - - - +C"
      ];

      boot.tmp.useTmpfs = true;

      system.stateVersion = "25.11";
    };
  };
}
