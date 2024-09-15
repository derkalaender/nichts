{ lib, config, pkgs, ...}:
with lib;
with lib.nichts;
let
  cfg = config.nichts.cli-apps.nix-tooling;
in
{
  options.nichts.cli-apps.nix-tooling = mkEnableOpt "nix tooling";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      unstable.nil # nix lsp
      unstable.nixd # another nix lsp
      unstable.alejandra # nix code formatter
      unstable.nh # better nix build output
    ];
  };
}
