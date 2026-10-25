{
  inputs,
  self,
  ...
}:
{
  flake.deploy.nodes.kawauso = {
    hostname = "kawauso";
    profiles.system.path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kawauso;
  };
}
