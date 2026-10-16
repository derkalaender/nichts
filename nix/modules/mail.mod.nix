{
  nichts.modules.home.mail = {
    programs.thunderbird = {
      enable = true;
      profiles.private = {
        isDefault = true;
      };
    };

    # TODO add mail accounts using Home Manager, encrypted with SOPS
  };
}
