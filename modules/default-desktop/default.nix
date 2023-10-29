{ config, pkgs, lib, ...}:
with lib;
let 
  cfg = config.my.desktop;
in
{
  # Add default user
  imports = [ ../../users/marvin.nix ];

  options.my.desktop = {
    enable = mkEnableOption "Default desktop configuration";

    stateVersion = mkOption {
      type = types.str;
      default = "23.05";
      description = "NixOS state version. Bump this only when you need to";
    };

    hostname = mkOption {
      type = types.str;
      example = "dot";
      description = "Hostname to identify this machine";
    };
  };

  config = mkIf cfg.enable {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
      neovim
      wget
      git
      curl
      jetbrains-mono
      time
    ];

    networking = {
      # Enable networking
      networkmanager.enable = true;
      # Set hostname to specified config value
      hostName = cfg.hostname;
      # Define Cloudflare DNS servers
      nameservers = [ "1.1.1.1" "1.0.0.1" ];
    };

    # Enable other default options
    my.defaults = {
      nix.enable = true;
      sound.enable = true;
      locale.enable = true;
      home-manager.enable = true;
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = cfg.stateVersion; # Did you read the comment?
  };
}