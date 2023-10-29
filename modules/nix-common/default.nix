{ config, lib, ... }:
with lib;
let cfg = config.my.defaults.nix;
in
{
  options.my.defaults.nix = { enable = mkEnableOption "Nix defaults"; };

  config = mkIf cfg.enable {
    # Allow unfree licensed packages
    nixpkgs.config.allowUnfree = true;

    # Options regarding nix package manager
    nix = {
      settings = {
        # Enable flakes and new nix CLI
        experimental-features = [ "nix-command" "flakes" ];

        # Save space by hardlinking store files
        # auto-optimise-store = true;
      };
    };
  };
}