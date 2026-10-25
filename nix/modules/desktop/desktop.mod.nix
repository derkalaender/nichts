{
  nichts,
  ...
}:
{
  # The desktop is one concept spread over several units; hosts import
  # `desktop` rather than listing the parts.
  nichts.modules.desktop.nixos = {
    imports = with nichts.lib.units.nixos; [
      desktop-base
      desktop-audio
      desktop-boot
      desktop-compat
      desktop-kde
      desktop-printing
    ];
  };

  nichts.modules.desktop.home = {
    imports = with nichts.lib.units.home; [
      desktop-kde
    ];
  };
}
