{nichts, ...}: let
  inherit (nichts.lib) fs;
in {
  nichts.aspects.deerlab._.users = {
    nixos = {config, ...}: {
      # Explicitly import the user NixOS module to avoid including aspects multiple times / recursion
      imports = with nichts.aspects; [
        (deerlab._.users._.dot.resolve {class = "nixos";})
      ];

      # User passwords
      sops.secrets."user_passwords/dot" = {
        sopsFile = fs.secret "deerlab.yaml";
        neededForUsers = true;
      };

      # User definitions
      users.users = {
        dot = {
          description = "Dot the Deer";
          isNormalUser = true;
          hashedPasswordFile = config.sops.secrets."user_passwords/dot".path;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGz0wxyVRtEAFeWUdjIH1c4Se3JJNr2qgpeKevJtePKs" # Deerlab
          ];
          extraGroups = ["wheel" "networkmanager"];
        };

        kyson = {
          description = "Kyson";
          isNormalUser = true;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItTurzE0yXGvSH38e6/iMkSGMAPw3lvNl63jjSO6H2H"
          ];
        };
      };

      home-manager.users.dot = {
        imports = with nichts.aspects; [
          (core.resolve {class = "homeManager";}) # Get defaults
          (deerlab.resolve {class = "homeManager";}) # Back-include the host HM config for host-specific defaults
          (deerlab._.users._.dot.resolve {class = "homeManager";}) # User specific stuff
        ];
      };

      home-manager.users.kyson = {
        imports = with nichts.aspects; [
          (core.resolve {class = "homeManager";}) # Get defaults
          (deerlab.resolve {class = "homeManager";}) # Back-include the host HM config for host-specific defaults
          (deerlab._.users._.kyson.resolve {class = "homeManager";}) # User specific stuff
        ];
      };
    };

    _.dot = {};

    _.kyson = {};
  };
}
