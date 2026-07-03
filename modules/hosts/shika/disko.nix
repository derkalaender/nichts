{
  flake.diskoConfigurations.shika = {
    disko = {
      devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-CT1000P3SSD8_2302E69DC0E7";
            content = {
              type = "gpt";
              partitions = {
                esp = {
                  priority = 1;
                  size = "4G"; # Big, in case of UKIs or similar
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = ["umask=0077"];
                    extraArgs = ["-nESP"]; # Label
                  };
                };
                root = {
                  end = "-64G"; # Leave space for swap
                  content = {
                    type = "btrfs";
                    extraArgs = [
                      "-L NixOS" # Label
                      "-d single -m dup" # Metadata duplication
                    ];
                    subvolumes = let
                      mountOptions = [
                        "compress=zstd:1" # Default is zstd:3, but lower is faster and still good compression
                        "noatime"
                      ];
                    in {
                      "@" = {
                        mountpoint = "/";
                        inherit mountOptions;
                      };
                      "@home" = {
                        mountpoint = "/home";
                        inherit mountOptions;
                      };
                      "@nix" = {
                        mountpoint = "/nix";
                        inherit mountOptions;
                      };
                      "@snapshots" = {
                        mountpoint = "/.snapshots";
                        inherit mountOptions;
                      };
                      "@var_log" = {
                        mountpoint = "/var/log";
                        inherit mountOptions;
                      };
                      "@var_lib" = {
                        mountpoint = "/var/lib";
                        inherit mountOptions;
                      };
                      "@games" = {
                        mountpoint = "/games";
                        inherit mountOptions;
                      };
                      "@models" = {
                        mountpoint = "/models";
                        inherit mountOptions;
                      };
                    };
                  };
                };
                swap = {
                  size = "100%";
                  content = {
                    type = "swap";
                    extraArgs = [
                      "-L Swap" # Label
                    ];
                    discardPolicy = "pages";
                    resumeDevice = true;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
