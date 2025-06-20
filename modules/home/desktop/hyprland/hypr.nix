{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
in {
  config = mkIf (config.wayland.windowManager.hyprland.enable) {
    wayland.windowManager.hyprland = {
      systemd.enable = false; # Conflicts with USWM

      settings = {
        "$terminal" = "ghostty";
        "$fileManager" = "nautilus";
        "$menu" = "rofi -show drun -run-command \"uwsm app -- {cmd}\"";
        "$browser" = "google-chrome-stable";
        "$asApp" = "uwsm app --";

        exec-once = [
          "gnome-keyring-daemon --start" # Initialize the GNOME Keyring so that apps can access it
        ];

        monitor = ", preferred, auto, auto";

        env = [
          "XCURSOR_SIZE, 24"
          "HYPRCURSOR_SIYE, 24"
          "SSH_AUTH_SOCK, $XDG_RUNTIME_DIR/keyring/ssh" # Use GNOME Keyring SSH agent
        ];

        general = {
          layout = "dwindle";
        };

        input = {
          kb_layout = "de";
          follow_mouse = 1;
        };

        # Eye Candy
        decoration = {
          rounding = 10;
          rounding_power = 2;

          active_opacity = 1.0;
          inactive_opacity = 0.95;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };

        animations = {
          enabled = true;

          bezier = "ease, 0.4, 0.02, 0.21, 1";

          animation = [
            "windows, 1, 3.5, ease, slide"
            "windowsOut, 1, 3.5, ease, slide"
            "border, 1, 6, default"
            "fade, 1, 3, ease"
            "workspaces, 1, 3.5, ease"
          ];
        };

        # Keybinds
        "$mod" = "SUPER";
        bind = [
          "$mod, Q, killactive"
          "$mod, F, togglefloating"
          "$mod, T, exec, $asApp $terminal"
          "$mod, E, exec, $asApp $fileManager"
          "$mod, R, exec, $menu"
          "$mod, B, exec, $asApp $browser"
          "$mod, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
