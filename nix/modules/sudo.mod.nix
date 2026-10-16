{
  nichts.modules.nixos.sudo = {
    # TODO: replace with run0
    security.sudo = {
      # Keep the upstream default of false. Setting this true makes the NixOS sudo
      # wrapper mode 4750 root:wheel, so only wheel members can execute it at all.
      # The btrbk module runs its service as the "btrbk" user and depends on a
      # NOPASSWD sudo rule for that user; with this enabled btrbk could not even
      # exec the wrapper ("/run/wrappers/bin/sudo: Permission denied") and every
      # run aborted, so no snapshots were taken from 2026-06-01 onwards. The
      # per-command sudoers rules still restrict what each user may run.
      execWheelOnly = false;
      # Show asterisks when typing password, no intro text
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
      '';
    };
  };
}
