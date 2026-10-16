{
  nichts,
  ...
}:
{
  # The desktop is one concept spread over several units; hosts import
  # `desktop` rather than listing the parts.
  nichts.modules.nixos.desktop = {
    imports = with nichts.modules.nixos; [
      desktop-base
      desktop-audio
      desktop-boot
      desktop-compat
      desktop-kde
      desktop-printing
    ];
  };

  nichts.modules.home.desktop = {
    imports = with nichts.modules.home; [
      desktop-kde
    ];
  };
}
