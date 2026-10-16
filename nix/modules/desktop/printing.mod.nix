{
  nichts.modules.nixos.desktop-printing = {pkgs, ...}: {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        epson-escpr
        epson-escpr2
      ];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
}
