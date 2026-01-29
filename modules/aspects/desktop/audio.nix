{
  nichts.aspects.desktop.nixos = {
    # See https://wiki.nixos.org/wiki/PipeWire#Configuring_PipeWire

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };
  };
}
