{
  nichts.aspects.tailscale.nixos = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      disableUpstreamLogging = true;
    };
  };
}
