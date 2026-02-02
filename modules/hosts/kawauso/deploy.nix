{
  inputs,
  self,
  ...
}: {
  flake.deploy.nodes.kawauso = {
    hostname = "192.168.178.70"; # TODO: tailscale-based hostname/IP
    profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kawauso;
  };
}
