{
  nichts.modules.home.git = {
    programs.git = {
      enable = true;

      settings = {
        # sign commits and tags by default
        commit.gpgSign = true;
        tag.gpgSign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

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
      };
    };

    programs.difftastic = {
      enable = true;
      git.enable = true;
    };
  };
}
