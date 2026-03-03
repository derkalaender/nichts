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
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
        virtualbox.host.enable = true;
      };

      programs.wireshark.enable = true;

      # Minecraft
      networking.firewall.allowedTCPPorts = [25565];
      networking.firewall.allowedUDPPorts = [25565];

      environment.systemPackages = with pkgs; [
        podman-compose
        kubectl
        k9s
        kubernetes-helm
        kustomize
        kind
        minikube
        kn
        fluxcd
        cloudflared
      ];

      system.stateVersion = "25.11";
    };
  };
}
