{ lib, config, pkgs, ... }:
with lib;
with lib.nichts;
let
  cfg = config.nichts.cli-apps.modern;
in
{
  options.nichts.cli-apps.modern = mkEnableOpt "modern CLI tool replacements";

  config = mkIf cfg.enable {
    # Modern, faster, often Rust-based replacements for old GNU tools

    # cat alternative
    programs.bat = enabled;

    # cd alternative
    programs.zoxide = enabled; # TODO fish integration if fish is enabled

    # grep alternative
    programs.ripgrep = enabled;

    # htop alternative (TODO checkout ytop, zenith?)
    programs.bottom = enabled;

    # ls alternative
    programs.eza = enabled; # TODO fish integration if fish is enabled

    home.packages = with pkgs; [
      unstable.gping # ping alternative
      sd # sed alternative
      unstable.fd # find alternative
      unstable.tokei # cloc alternative
      jaq # jq alternative (json tooling)
    ];
  };
}
