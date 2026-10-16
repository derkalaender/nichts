{
  nichts,
  ...
}:
{
  # The desktop is one concept spread over several units; hosts import
  # `desktop` rather than listing the parts.
  nichts.modules.desktop.nixos = {
    imports = with nichts.modules; [
      desktop-base.nixos
      desktop-audio.nixos
      desktop-boot.nixos
      desktop-compat.nixos
      desktop-kde.nixos
      desktop-printing.nixos
    ];
  };

  nichts.modules.desktop.home = {
    imports = with nichts.modules; [
      desktop-kde.home
    ];
  };
}
