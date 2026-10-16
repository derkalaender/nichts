{ nichts, ... }: {
  nichts.modules.docker.nixos = { pkgs, ... }: {
    virtualisation = {
      docker.enable = true;
      # virtualbox.host.enable = true;
    };

    environment.systemPackages = with pkgs; [
      docker-credential-helpers
      docker-compose
    ];
  };
}
