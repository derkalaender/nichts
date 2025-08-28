{channels, ...}: final: prev: {
  deploy-rs = {
    inherit (channels.nixpkgs) deploy-rs;
    lib = prev.deploy-rs.lib;
  };
}
