{...}: {
  nichts.modules.nixos.btrfs = {
    config,
    lib,
    ...
  }: {
    options.nichts.btrfs.fileSystems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Filesystems to scrub on a weekly schedule.";
    };

    config = {
      services.btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = config.nichts.btrfs.fileSystems;
      };

      # Sysctl config for btrfs drive from CachyOS https://github.com/CachyOS/CachyOS-Settings/blob/9c623471493d8faa22614ee5eecbd59a6d028b53/usr/lib/sysctl.d/70-cachyos-settings.conf
      boot.kernel.sysctl = {
        "vm.dirty_bytes" = 256 * 1024 * 1024; # 256MiB, means more flushes so it doesn't stall on large writes (default 10% of RAM, so 6.4GiB)
        "vm.dirty_background_bytes" = 64 * 1024 * 1024; # 64MiB, same as above but for kernel background flusher
        "vm.dirty_expire_centisecs" = 15 * 1000; # 15s, higher than default 5s means flushes will be batched together more if we don't exceed the above limits
        "vm.vfs_cache_pressure" = 50; # default is 100, lower means the kernel will prefer to keep file data in RAM which is good on btrfs where metadata can be large
      };
    };
  };
}
