{ nichts, ... }: {
  nichts.modules.minecraft.nixos = {
    # Minecraft
    networking.firewall.allowedTCPPorts = [ 25565 ];
    networking.firewall.allowedUDPPorts = [ 25565 ];
  };
}
