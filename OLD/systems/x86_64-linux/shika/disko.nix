{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-nvme.c0a9-323330324536394443304537-435431303030503353534438-00000001";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
                extraArgs = ["-n" "ESP"]; # needed for rEFInd
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  # Subvolume name is different from mountpoint
                  "/rootfs" = {
                    mountpoint = "/";
                  };
                  # Subvolume name is the same as the mountpoint
                  "/home" = {
                    mountOptions = ["compress=zstd"];
                    mountpoint = "/home";
                  };
                  # Parent is not mounted so the mountpoint must be set
                  "/nix" = {
                    mountOptions = ["compress=zstd" "noatime"];
                    mountpoint = "/nix";
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
