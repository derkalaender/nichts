{
  config,
  nichts,
  ...
}: {
  nichts.aspects.hosts._.kawauso = {
    includes = with nichts.aspects; [
      deerlab
      deerlab._.k3s
      deerlab._.k3s._.server
    ];

    nixos = {
      # Disk configuration via disko
      inherit (config.flake.diskoConfigurations.kawauso) disko;

      # Additional hardware config via facter
      hardware.facter.reportPath = ./facter.json;

      # Set network hostname to host configuration name
      networking.hostName = "kawauso";

      # Minecraft
      networking.firewall.allowedTCPPorts = [25565];
      networking.firewall.allowedUDPPorts = [25565];

      system.stateVersion = "25.11";
    };
  };
}
