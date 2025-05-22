{
  lib,
  config,
  osConfig,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types mkIf;
  cfg = config.nichts.git;
in {
  options = {
    nichts.git = {
      enable = mkEnableOption "git configuration";
      # local path to ssh signing key
      sshSigningKey = mkOption {
        type = types.str;
        default = null;
        description = ''
          Path to the ssh signing key. This is used to sign commits with ssh keys.
        '';
      };
      username = mkOption {
        type = types.str;
        default = null;
        description = ''
          The name to use for git commits.
        '';
      };
      email = mkOption {
        type = types.str;
        default = null;
        description = ''
          The email to use for git commits.
        '';
      };
    };
  };

  # Adapted from https://github.com/RGBCube/ncc/blob/master/modules/common/git.nix and https://github.com/NelsonJeppesen/nix-lifestyle/blob/main/home-manager/git.nix
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      package = osConfig.programs.git.package;

      userName = cfg.username;
      userEmail = cfg.email;

      difftastic.enable = true; # difftastic understands languages

      extraConfig = {
        # sign commits and tags by default
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        user.signingKey = cfg.sshSigningKey;

        init.defaultBranch = "main";
        commit.verbose = true;

        branch.sort = "-committerdate";
        tag.sort = "version:refname";

        diff.algorithm = "histogram";
        diff.colorMoved = true;

        push.autoSetupRemote = true;

        merge.conflictStyle = "zdiff3";

        rerere.enabled = true; # remembers how to resolve conflicts

        # check for broken objects
        fetch.fsckObjects = true;
        receive.fsckObjects = true;
        transfer.fsckobjects = true;

        # replaces public http github links with ssh links so that we can always authenticate
        url."ssh://git@github.com/".insteadOf = "https://github.com/";
      };
    };
  };
}
