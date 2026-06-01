let
  inherit (builtins) listToAttrs;
in {
  nichts.aspects.hosts._.shika = {
    nixos = {
      # Regular snapshots
      services.btrbk.instances.local = {
        onCalendar = "daily";
        settings = {
          snapshot_preserve_min = "2d";
          snapshot_preserve = "14d 8w 12m";

          volume = {
            "/" = {
              snapshot_dir = ".snapshots";
              subvolume =
                [
                  {
                    subvolume = "@";
                    name = "root";
                  }
                  {
                    subvolume = "@home";
                    name = "home";
                  }
                  {
                    subvolume = "@var_lib";
                    name = "var_lib";
                  }
                ]
                |> map (x: {
                  name = x.subvolume;
                  value = {snapshot_name = x.name;};
                })
                |> listToAttrs;
            };
          };
        };
      };
    };
  };
}
