{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.nichts; let
  cfg = config.nichts.cli.nix-tooling;
in {
  options.nichts.cli.nix-tooling = mkEnableOpt "nix tooling";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      unstable.nil # nix lsp
      unstable.nixd # another nix lsp
      unstable.alejandra # nix code formatter
      # unstable.nh # Already included system-wide
      unstable.nix-index # nix package search
    ];

    # direnv for automatic environment management
    programs.direnv = {
      enable = true;
      package = pkgs.unstable.direnv;
      nix-direnv.enable = true;
    };
  };
}
