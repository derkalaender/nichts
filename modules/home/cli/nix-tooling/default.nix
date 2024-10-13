{ lib, config, pkgs, ...}:
with lib;
with lib.nichts;
let
  cfg = config.nichts.cli.nix-tooling;
in
{
  options.nichts.cli.nix-tooling = mkEnableOpt "nix tooling";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.nil # nix lsp
      unstable.nixd # another nix lsp
      unstable.alejandra # nix code formatter
      unstable.nh # better nix build output
      unstable.nix-index # nix package search
    ];
  };
}