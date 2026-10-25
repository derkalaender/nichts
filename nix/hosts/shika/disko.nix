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
                    mountOptions = [ "umask=0077" ];
                    extraArgs = [ "-nESP" ]; # Label
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
                    subvolumes =
                      let
                        mountOptions = [
                          "compress=zstd:1" # Default is zstd:3, but lower is faster and still good compression
                          "noatime"
                        ];
                      in
                      {
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

          games = {
            type = "disk";
            device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2130E5BBF0C9";
            content = {
              type = "gpt";
              partitions = {
                games = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "btrfs";
                    mountpoint = "/games";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                    ];
                    extraArgs = [
                      "-L Games"
                      "-d single -m dup"
                    ];
                  };
                };
              };
            };
          };

          projects = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-CT1000P5SSD8_21313086879A";
            content = {
              type = "gpt";
              partitions = {
                projects = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "btrfs";
                    mountpoint = "/projects";
                    mountOptions = [
                      "noatime"
                      "compress=zstd:1"
                    ];
                    extraArgs = [
                      "-L Projects"
                      "-d single -m dup"
                    ];
                  };
                };
              };
            };
          };

          archive1 = {
            type = "disk";
            device = "/dev/disk/by-id/ata-SanDisk_Ultra_II_480GB_161223800955";
            content = {
              type = "gpt";
              partitions = {
                archive1 = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "btrfs";
                    mountpoint = "/mnt/archive1";
                    mountOptions = [
                      "noatime"
                      "compress=zstd:1"
                    ];
                    extraArgs = [
                      "-L Archive1"
                      "-d single -m dup"
                    ];
                  };
                };
              };
            };
          };

          archive2 = {
            type = "disk";
            device = "/dev/disk/by-id/ata-CT2000BX500SSD1_2245E682AD76";
            content = {
              type = "gpt";
              partitions = {
                archive2 = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "btrfs";
                    mountpoint = "/mnt/archive2";
                    mountOptions = [
                      "noatime"
                      "compress=zstd:1"
                    ];
                    extraArgs = [
                      "-L Archive2"
                      "-d single -m dup"
                    ];
                  };
                };
              };
            };
          };

          archive = {
            type = "filesystem";
            device = "/mnt/archive1:/mnt/archive2";
            content = {
              type = "filesystem";
              format = "fuse.mergerfs";
              mountpoint = "/archive";

              mountOptions = [
                "noatime"
                "defaults"
                "allow_other"
                "use_ino"
                "cache.files=partial"
                "cache.readdir=true"
                "dropcacheonclose=true"
                "category.create=pfrd"
                "minfreespace=25G"
                "moveonenospc=true"
                "fsname=Archive"
              ];
            };
          };
        };
      };
    };
  };
}
