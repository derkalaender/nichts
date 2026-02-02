{
  config,
  nichts,
  ...
}: {
  nichts.aspects.hosts._.kawauso = {
    includes = with nichts.aspects; [
      deerlab
    ];

    nixos = {
      # Disk configuration via disko
      inherit (config.flake.diskoConfigurations.kawauso) disko;

      # Additional hardware config via facter
      hardware.facter.reportPath = ./facter.json;

      # Set network hostname to host configuration name
      networking.hostName = "kawauso";

      system.stateVersion = "25.11";
    };
  };
}
