{
  lib,
  nichts,
  ...
}: let
  inherit (builtins) listToAttrs;
  inherit (lib) getExe concatStringsSep nameValuePair;
  inherit (nichts.lib) fs;
in {
  nichts.aspects.hosts._.shika = {
    includes = with nichts.aspects; [
      rustic
    ];

    nixos = {
      pkgs,
      config,
      ...
    }: let
      backups = [
        {
          subvolume = "/";
          name = "root";
        }
        {
          subvolume = "/home";
          name = "home";
        }
        {
          subvolume = "/var/lib";
          name = "var_lib";
        }
      ];
      snapshotDir = "/.snapshots";
      backupTarget = "shika";
    in {
      # Regular snapshots
      services.btrbk.instances.local = {
        onCalendar = "hourly";
        settings = {
          snapshot_preserve_min = "2d";
          snapshot_preserve = "14d 8w 12m";

          snapshot_dir = snapshotDir;
          subvolume =
            backups
            |> map (x: nameValuePair x.subvolume {snapshot_name = x.name;})
            |> listToAttrs;
        };
      };

      sops.secrets =
        ["backup/master-key" "backup/ssh-key"]
        |> map (secret: nameValuePair secret {sopsFile = fs.secret "backup_shika.yaml";})
        |> listToAttrs;

      # Remote off-site backups using rustic
      services.rustic.profiles.hetzner = let
        btrfs = getExe pkgs.btrfs-progs;
        createSnapshots =
          backups
          |> map (x: ''${btrfs} subvolume snapshot -r "${x.subvolume}" "${snapshotDir}/backup/${x.name}"'')
          |> concatStringsSep "\n";
        deleteSnapshots =
          backups
          |> map (x: ''${btrfs} subvolume delete ${snapshotDir}/backup/${x.name} 2>/dev/null || true'')
          |> concatStringsSep "\n";
      in {
        startAt = "daily";
        persistentTimer = true;
        # persistentTimer catches up a missed run at boot, which raced DNS: the
        # service failed with "Could not resolve hostname u530494.your-storagebox.de".
        waitForNetwork = true;
        preHook = ''
          mkdir -p "${snapshotDir}/backup"
          # Clean up old snapshots
          ${deleteSnapshots}
          # Create new snapshots
          ${createSnapshots}
        '';
        postHook = deleteSnapshots; # clean up snapshots after backup
        additionalPath = [pkgs.openssh]; # needed for sftp
        config = {
          repository = {
            # Use sftp
            repository = "opendal:sftp";
            key-file = config.sops.secrets."backup/master-key".path;
            options = {
              endpoint = "ssh://u530494.your-storagebox.de:23";
              user = "u530494";
              key = config.sops.secrets."backup/ssh-key".path;
              root = "/home/backups/${backupTarget}";
              known_hosts_strategy = "Accept"; # auto-accept on first connect, otherwise connection timeout
            };
          };
          backup = {
            # Don't cross filesystem boundaries
            one-file-system = true;
            # Don't backup ignored files
            git-ignore = true;
            no-require-git = true;
            # Exclude these patterns
            globs = [
              "!**/.cache"
              "!**/.cargo"
              "!**/.rustup"
              "!**/node_modules"
              "!**/.nix-profile"
              "!**/.venv"
              "!**/.direnv"
            ];

            snapshots =
              backups
              |> map (x: {
                inherit (x) name;
                sources = ["${snapshotDir}/backup/${x.name}"];
              });
          };
          forget = {
            # Clean up the actual space used
            prune = true;
            # Retention policy
            keep-last = 10;
            keep-daily = 7;
            keep-weekly = 5;
            keep-monthly = 12;
            keep-yearly = 2;
          };
        };
      };
    };
  };
}
