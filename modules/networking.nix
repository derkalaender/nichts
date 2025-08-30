{
  flake.modules.nixos.core = {host, ...}: {
    networking.hostName = host;
  };
}
