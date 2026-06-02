{
  nichts.aspects.rustic.nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit
      (lib)
      mkEnableOption
      mkIf
      mkOption
      mkPackageOption
      types
      mapAttrs'
      nameValuePair
      filterAttrs
      concatStringsSep
      escapeShellArg
      escapeShellArgs
      mapAttrsToList
      getExe
      optionals
      optionalString
      ;

    cfg = config.services.rustic;

    tomlFormat = pkgs.formats.toml {}; # for serializing our profile config to TOML

    mkEnvExports = env:
      concatStringsSep "\n" (
        mapAttrsToList (k: v: ''export ${k}=${escapeShellArg v}'') env
      );

    mkProfileConfigFile = profName: profCfg: let
      fileName = "${profName}.toml";
    in
      nameValuePair "rustic/${fileName}" {
        source = tomlFormat.generate "rustic-${profName}.toml" profCfg.config; # profCfg.config is a Nix attrset matching rustic's TOML schema
      };

    mkProfileService = profName: profCfg: let
      serviceName = "rustic-backup-${profName}";
      rusticBin = getExe cfg.package;
      backupCmd = ''
        ${rusticBin} -P ${escapeShellArg profName} \
          backup ${escapeShellArgs profCfg.extraBackupArgs}
      '';
      forgetCmd = ''
        ${rusticBin} -P ${escapeShellArg profName} \
          forget ${escapeShellArgs profCfg.extraForgetArgs}
      '';
    in
      nameValuePair serviceName {
        description = "Rustic backup profile ${profName}";

        path = [cfg.package] ++ profCfg.additionalPath;

        script = ''
          set -e

          on_exit() {
            local _exit_status=$?
            ${profCfg.postHook}
            exit $_exit_status
          }
          trap on_exit EXIT

          ${profCfg.preHook}

          ${mkEnvExports profCfg.environment}

          # Run backup (uses [global], [repository], [backup] etc. from the profile TOML)
          ${backupCmd}

          # Optionally run forget/prune according to [forget] options in the profile TOML[file:2]
          ${optionalString profCfg.runForget forgetCmd}
        '';

        serviceConfig = {
          # Type = "oneshot";
          User = profCfg.user;
          Group = profCfg.group;

          # Only run when no other process is using CPU or disk to avoid performance issues
          CPUSchedulingPolicy = "idle";
          IOSchedulingClass = "idle";

          # You can harden this similarly to the Borg module if desired
          # ProtectSystem = "strict";
          # PrivateTmp = true;
          # ReadWritePaths = [ ... ];
        };

        # Wait for network if requested
        after = optionals profCfg.waitForNetwork ["network-online.target"];
        wants = optionals profCfg.waitForNetwork ["network-online.target"];
      };

    mkProfileTimer = name: profCfg:
      nameValuePair "rustic-backup-${name}" {
        description = "Rustic backup profile ${name} timer";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnCalendar = profCfg.startAt;
          Persistent = profCfg.persistentTimer;
        };
      };
  in {
    ###### interface

    options.services.rustic = {
      enable = mkEnableOption "Rustic backups (restic-compatible, implemented in Rust)";

      package = mkPackageOption pkgs "rustic" {};

      profiles = mkOption {
        type = types.attrsOf (
          types.submodule
          ({name, ...}: {
            options = {
              user = mkOption {
                type = types.str;
                default = "root";
                description = "User to run rustic as.";
              };

              group = mkOption {
                type = types.str;
                default = "root";
                description = "Group to run rustic as.";
              };

              additionalPath = mkOption {
                type = types.listOf types.package;
                default = [];
                description = "Extra packages added to PATH for this profile (e.g. rclone).";
              };

              startAt = mkOption {
                type = with types; either str (listOf str);
                default = "daily";
                description = ''
                  When/how often to run this backup, using systemd.time(7) OnCalendar syntax.
                  If you don't want automatic runs, set to [] and trigger the service manually.
                '';
              };

              persistentTimer = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  Whether the timer should be Persistent (run once at boot if it missed a scheduled time).
                '';
              };

              waitForNetwork = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  If true, require network-online.target before running the backup service.
                  Useful if persistentTimer is used, as network may not be up at boot.
                '';
              };

              runForget = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  If true, run "rustic forget" right after "rustic backup" for this profile.
                  Retention is configured in the profile's [forget] section.
                '';
              };

              extraBackupArgs = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "Extra CLI args appended to `rustic backup` for this profile.";
              };

              extraForgetArgs = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "Extra CLI args appended to `rustic forget` for this profile.";
              };

              environment = mkOption {
                type = types.attrsOf types.str;
                default = {};
                description = ''
                  Environment variables exported before running rustic, e.g. RUSTIC_REPO_OPT_* or rclone vars.
                '';
              };

              preHook = mkOption {
                type = types.lines;
                default = "";
                description = ''
                  Shell commands to run before rustic is invoked for this profile.
                  Executed in the service shell environment.
                '';
              };

              postHook = mkOption {
                type = types.lines;
                default = "";
                description = ''
                  Shell commands to run after rustic backup/forget has completed.
                  Executed only if the script reaches the end successfully.
                '';
              };

              config = mkOption {
                type = tomlFormat.type;
                description = ''
                  Rustic profile configuration as a Nix attrset, serialized to TOML.
                  This should contain keys like "global", "repository", "backup", "forget", etc.,
                  matching the rustic config spec.
                '';
              };
            };
          })
        );
        default = {};
        description = "Rustic backup profiles. Each entry becomes a <name>.toml profile and a systemd job.";
      };
    };

    ###### implementation

    config = mkIf (cfg.profiles != {}) {
      # TODO tmpfiles?

      # services.rustic.profiles.<name> -> /etc/rustic/<name>.toml
      environment.etc =
        cfg.profiles
        |> mapAttrs' mkProfileConfigFile;

      # services.rustic.profiles.<name> -> systemd.services.rustic-backup-<name>
      systemd.services =
        cfg.profiles
        |> mapAttrs' mkProfileService;

      # services.rustic.profiles.<name> -> systemd.timers.rustic-backup-<name> if startAt is set
      systemd.timers =
        cfg.profiles
        |> filterAttrs (_: cfg: cfg.startAt != [])
        |> mapAttrs' mkProfileTimer;

      # Make rustic available system‑wide
      environment.systemPackages = [cfg.package];
    };
  };
}
