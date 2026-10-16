{ lib, ... }: {
  nichts.modules.nixos.tailscale = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      disableUpstreamLogging = true;
      useRoutingFeatures = lib.mkDefault "client"; # Loosens spoofing checks to allow subnet routing
      extraSetFlags = [
        "--accept-routes" # Accept subnet routes
      ];
    };
  };
}
