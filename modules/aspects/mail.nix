{
  nichts.aspects.mail.homeManager = {
    programs.thunderbird = {
      enable = true;
      profiles.private = {
        isDefault = true;
      };
    };

    # TODO add mail accounts using Home Manager, encrypted with SOPS
  };
}
