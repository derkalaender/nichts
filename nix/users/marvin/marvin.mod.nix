{ nichts, lib, ... }:
let
  inherit (lib) mkMerge;
in
{
  nichts.entities.users.marvin = {
    description = "Marvin UwU";
    extraGroups = [
      "wheel"
      "networkmanager"
      "gamemode"
      "wireshark"
      "dialout"
      "docker"
      "video"
      "render"
      "fuse"
      "lp"
    ];

    module =
      {
        config,
        pkgs,
        ...
      }:
      {
        imports = with nichts.lib.units.home; [
          spotify
          editor
          atuin
          terminal
          browser
          git
          ssh
          bitwarden
          mail
          blender
          affinity
          davinci-resolve
          llm-agents
          nuvio
        ];

        config = mkMerge [
          {
            home.packages = with pkgs; [
              vlc
              xpipe
              distrobox
              # anki # TODO: Build failure
              eduvpn-client
              # stremio-linux-shell
              rapidraw
              bruno
              jabref
            ];

            programs.vesktop = {
              enable = true;
            };

            # Vesktop writes ~/.config/autostart/vesktop.desktop itself, with the
            # absolute /nix/store paths that existed the day autostart was enabled.
            # Those go stale on the next update: the pinned electron's glibc no
            # longer matches the system mesa, so it dies with SIGILL at login while
            # still starting fine from the launcher. Own the file here so it is
            # regenerated with the current package on every switch.
            #
            # xdg.desktopEntries cannot be used for this: it installs launcher
            # entries into ~/.local/share/applications, and autostart is read from
            # ~/.config/autostart.
            xdg.configFile."autostart/vesktop.desktop" = {
              force = true;
              source = "${
                pkgs.makeDesktopItem {
                  name = "vesktop";
                  desktopName = "Vesktop";
                  comment = "Vesktop autostart script";
                  exec = "${config.programs.vesktop.package}/bin/vesktop %U";
                  icon = "vesktop";
                  terminal = false;
                  startupNotify = false;
                }
              }/share/applications/vesktop.desktop";
            };

            programs.git.settings.user = {
              name = "Marvin";
              email = "git@mrvnbr.de";
              signingKey = "${config.home.homeDirectory}/.ssh/id_git_signing.pub";
            };

            services.tailscale-systray.enable = true;

            # Set Git signing key
            home.file.".ssh/id_git_signing.pub".text =
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJvy9JFQDNhfbOXft1V8AHp1exrz1nzTp4KUZ7vqlK3p";

            sops = {
              age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
              secrets = {
                "atuin/key" = {
                  sopsFile = ./secrets/atuin.yaml;
                };

                "atuin/session" = {
                  sopsFile = ./secrets/atuin.yaml;
                };
              };
            };

            nichts.atuin = {
              key = config.sops.secrets."atuin/key".path;
              session = config.sops.secrets."atuin/session".path;
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
              programs.ssh.settings.${entry.name} = {
                User = entry.user;
                HostName = entry.host;
                IdentityFile = "${config.home.homeDirectory}/.ssh/id_${entry.name}.pub";
                IdentitiesOnly = true;
              };
            })
            |> mkMerge
          )
        ];
      };
  };
}
