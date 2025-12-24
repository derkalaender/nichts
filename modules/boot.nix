{
  flake.modules.nixos.core = {
    # Use limine by default
    boot.loader = {
      efi.canTouchEfiVariables = true;

      limine = {
        enable = true;
        efiSupport = true;
        enableEditor = false; # Otherwise, can easily get root
        validateChecksums = true; # Verify integrity
        panicOnChecksumMismatch = true;
        maxGenerations = 10; # For GC
      };
    };
  };

  flake.modules.nixos.secureboot = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib.nichts) fs;
  in {
    secureboot.enable = true;

    # Key management
    environment.systemPackages = with pkgs; [
      sbctl
    ];

    # Provision PKI bundle with sops
    sops = {
      secrets = let
        mkSecret = path: {
          format = "binary";
          sopsFile = "${fs.secrets}/secureboot/${path}";
          path = "/var/lib/sbctl";
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

  flake.modules.nixos.desktop = {self, ...}: {
    # Desktops have secure boot by default
    imports = [
      # self.flake.modules.nixos.secureboot
    ];
  };
}
