{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf mkEnableOption mkOption types;
  inherit (lib.nichts) fs;
  cfg = config.nichts.security.secureboot;
in {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options = {
    nichts.security.secureboot = {
      enable = mkEnableOption "Secure Boot with Lanzaboote";
      pkiBundle = mkOption {
        type = types.path;
        default = "/var/lib/sbctl";
        description = "Path to the PKI bundle for Lanzaboote.";
      };
      configurationLimit = mkOption {
        type = types.int;
        default = 10;
        description = "Maximum number of configurations to keep in the Lanzaboote database.";
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      # Forcefully deactivate systemd-boot for Lanzaboote
      loader.systemd-boot.enable = lib.mkForce false;
      loader.efi.canTouchEfiVariables = true;

      lanzaboote = {
        enable = true;
        inherit (cfg) pkiBundle;
        configurationLimit = cfg.configurationLimit;
      };
    };

    # For debugging and troubleshooting Secure Boot
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    # Provision PKI bundle with sops
    sops = {
      secrets = let
        mkSecret = path: {
          format = "binary";
          sopsFile = "${fs.secrets}/secureboot/${path}";
          path = "${cfg.pkiBundle}/${path}";
        };
      in {
        secureboot-guid = mkSecret "GUID";
        secureboot-pk-key = mkSecret "keys/PK/PK.key";
        secureboot-pk-pem = mkSecret "keys/PK/PK.pem";
        secureboot-kek-key = mkSecret "keys/KEK/KEK.key";
        secureboot-kek-pem = mkSecret "keys/KEK/KEK.pem";
        secureboot-db-key = mkSecret "keys/db/db.key";
        secureboot-db-pem = mkSecret "keys/db/db.pem";
      };
    };
  };
}
