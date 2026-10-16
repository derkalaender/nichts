{ nichts, ... }: {
  nichts.modules.nixos.docker = { pkgs, ... }: {
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
