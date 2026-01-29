{
  nichts,
  lib,
  ...
}: let
  inherit (nichts.lib) fs;
  inherit (lib) mkMerge;
in {
  nichts.aspects.hosts._.shika._.users = {
    nixos = {config, ...}: {
      # Explicitly import the user NixOS module to avoid including aspects multiple times / recursion
      imports = with nichts.aspects; [
        (hosts._.shika._.users._.marvin.resolve {class = "nixos";})
      ];

      users.users = {
        marvin = {
          description = "Marvin UwU";
          isNormalUser = true;
          hashedPasswordFile = config.sops.secrets."user_passwords/marvin".path;
          extraGroups = ["wheel" "networkmanager" "gamemode" "wireshark" "vboxusers"];
        };
      };

      home-manager.users.marvin = {
        imports = with nichts.aspects; [
          (core.resolve {class = "homeManager";}) # Get defaults
          (hosts._.shika.resolve {class = "homeManager";}) # Back-include the host HM config for host-specific defaults
          (hosts._.shika._.users._.marvin.resolve {class = "homeManager";}) # User specific stuff
        ];
      };
    };

    _.marvin = {
      includes = with nichts.aspects; [
        spotify
        editor
        atuin
        terminal
        browser
        git
        ssh
        bitwarden
      ];

      homeManager = {
        config,
        pkgs,
        ...
      }:
        mkMerge [
          {
            home.packages = with pkgs; [
              vlc
              xpipe
              distrobox
              anki
              eduvpn-client
              # stremio # TODO: Re-enable once https://github.com/NixOS/nixpkgs/issues/437992 is fixed and https://github.com/NixOS/nixpkgs/pull/468728 is merged; TLDR: old stremio client uses insecure qt5 package, new one isn't ready yet
            ];

            programs.vesktop = {
              enable = true;
            };

            programs.git.settings.user = {
              name = "Marvin";
              email = "git@mrvnbr.de";
              signingKey = "${config.home.homeDirectory}/.ssh/id_git_signing.pub";
            };

            # Set Git signing key
            home.file.".ssh/id_git_signing.pub".text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJvy9JFQDNhfbOXft1V8AHp1exrz1nzTp4KUZ7vqlK3p";

            sops = {
              age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
              defaultSopsFile = fs.secret "user_marvin.yaml";
            };
          }

          (
            # Set SSH authentication keys for various hosts
            [
              {
                name = "github";
                host = "github.com";
                user = "git";
                publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBD4OW0HtjX/EsoeMqt4sbWI4S6GoDG+6YrY0DHahZFi";
              }
              {
                name = "lxhalle";
                host = "lxhalle.in.tum.de";
                user = "bauerm";
                publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXDYSSaINsDgni/iC2JwUTrPJNiWjp8NHkMiPWIWo8w";
              }
            ]
            |> map (entry: {
              home.file.".ssh/id_${entry.name}.pub".text = "${entry.publicKey}\n";
              programs.ssh.matchBlocks.${entry.name} = {
                user = entry.user;
                hostname = entry.host;
                identityFile = "${config.home.homeDirectory}/.ssh/id_${entry.name}.pub";
                identitiesOnly = true;
              };
            })
            |> mkMerge
          )
        ];
    };
  };
}
