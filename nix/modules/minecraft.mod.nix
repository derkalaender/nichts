{ nichts, ... }: {
  nichts.modules.nixos.minecraft = {
    # Minecraft
    networking.firewall.allowedTCPPorts = [ 25565 ];
    networking.firewall.allowedUDPPorts = [ 25565 ];
  };
}
