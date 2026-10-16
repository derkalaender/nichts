# https://github.com/NixOS/nixpkgs/blob/64c08a7ca051951c8eae34e3e3cb1e202fe36786/pkgs/by-name/da/davinci-resolve/package.nix
{
  lib,
  buildFHSEnv,
  bash,
  writeText,
  alsa-lib,
  aprutil,
  bzip2,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  libGL,
  libGLU,
  libarchive,
  libcap,
  librsvg,
  libtool,
  libuuid,
  libxcrypt,
  libxkbcommon,
  nspr,
  ocl-icd,
  opencl-headers,
  python3,
  udev,
  xdg-utils,
  xkeyboard_config,
  zlib,
  curl,
  jq,
  common-updater-scripts,
  writeShellApplication,
  writeShellScript,
  studioVariant ? false,
  davinci-resolve-unwrapped,
}:
let
  davinci = davinci-resolve-unwrapped;
in
buildFHSEnv {
  inherit (davinci) pname version;

  targetPkgs =
    pkgs: with pkgs; [
      alsa-lib
      aprutil
      bzip2
      davinci
      dbus
      expat
      fontconfig
      freetype
      glib
      libGL
      libGLU
      libarchive
      libcap
      librsvg
      libtool
      libuuid
      libxcrypt # provides libcrypt.so.1
      libxkbcommon
      nspr
      ocl-icd
      opencl-headers
      python3
      python3.pkgs.numpy
      libdrm # libdrm.so.2 needed by bundled Qt6 WebEngine (Control Panels Setup)
      libxkbfile # libxkbfile.so.1 needed by bundled Qt6 WebEngine (Control Panels Setup)
      krb5 # libgssapi_krb5.so.2 needed by bundled Qt6 (Control Panels Setup, Fairlight Studio Utility)
      nss # libsmime3.so needed by bundled Qt6 (Control Panels Setup)
      libxcb-cursor # libxcb-cursor.so needed by Qt6 xcb platform plugin (Fairlight Studio Utility)
      udev
      xdg-utils # xdg-open needed to open URLs
      libice
      libsm
      libx11
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxinerama
      libxrandr
      libxrender
      libxt
      libxtst
      libxxf86vm
      libxcb
      libxcb-util
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      xkeyboard-config
      zlib
    ];

  # These are not needed and conflict with our patches.

  # extraPreBwrapCmds = lib.optionalString studioVariant ''
  #   mkdir -p ~/.local/share/DaVinciResolve/license || exit 1
  #   mkdir -p ~/.local/share/DaVinciResolve/Extras || exit 1
  # '';

  # extraBwrapArgs = lib.optionals studioVariant [
  #   ''--bind "$HOME"/.local/share/DaVinciResolve/license ${davinci}/.license''
  #   ''--bind "$HOME"/.local/share/DaVinciResolve/Extras ${davinci}/Extras''
  # ];

  runScript = "${bash}/bin/bash ${writeText "davinci-wrapper" ''
    export QT_XKB_CONFIG_ROOT="${xkeyboard_config}/share/X11/xkb"
    export QT_PLUGIN_PATH="${davinci}/libs/plugins:$QT_PLUGIN_PATH"
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib32:${davinci}/libs
    if [ $# -gt 0 ]; then
      exec "$@"
    else
      exec ${davinci}/bin/resolve
    fi
  ''}";

  extraInstallCommands =
    let
      execName = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      # Each wrapper re-enters the FHS environment and execs a different binary
      mkWrapper =
        name: bin:
        writeShellScript name ''
          exec "$(dirname "$0")/${execName}" ${bin} "$@"
        '';
      wrappers = {
        "blackmagicraw-player" = "${davinci}/BlackmagicRAWPlayer/BlackmagicRAWPlayer";
        "blackmagicraw-speedtest" = "${davinci}/BlackmagicRAWSpeedTest/BlackmagicRAWSpeedTest";
        "davinci-control-panels-setup" =
          ''"${davinci}/DaVinci Control Panels Setup/DaVinci Control Panels Setup"'';
        "davinci-fairlight-studio-utility" =
          ''"${davinci}/Fairlight Studio Utility/Fairlight Studio Utility"'';
      }
      // lib.optionalAttrs studioVariant {
        "davinci-remote-monitor" = ''"${davinci}/bin/DaVinci Remote Monitor"'';
      };
    in
    ''
      # Desktop files
      mkdir -p $out/share/applications
      ln -s ${davinci}/share/applications/*.desktop $out/share/applications/

      # Icons
      mkdir -p $out/share/icons/hicolor/{128x128,256x256}/apps
      ln -s ${davinci}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve${lib.optionalString studioVariant "-studio"}.png
      ln -s ${davinci}/graphics/DV_Panels.png $out/share/icons/hicolor/128x128/apps/davinci-control-panels-setup.png
      ${lib.optionalString studioVariant ''
        ln -s ${davinci}/graphics/Remote_Monitoring.png $out/share/icons/hicolor/128x128/apps/davinci-remote-monitor.png
      ''}
      ln -s ${davinci}/graphics/blackmagicraw-player_256x256_apps.png $out/share/icons/hicolor/256x256/apps/blackmagicraw-player.png
      ln -s ${davinci}/graphics/blackmagicraw-speedtest_256x256_apps.png $out/share/icons/hicolor/256x256/apps/blackmagicraw-speedtest.png

      # Wrapper scripts for additional programs
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: bin: ''
          ln -s ${mkWrapper name bin} $out/bin/${name}
        '') wrappers
      )}

      # MIME type definitions for .drp, .braw, etc.
      mkdir -p $out/share/mime/packages
      ln -s ${davinci}/share/resolve.xml $out/share/mime/packages/
      ln -s ${davinci}/share/blackmagicraw.xml $out/share/mime/packages/

      # Expose udev rules so NixOS can aggregate them from environment.systemPackages
      mkdir -p $out/lib/udev/rules.d
      ln -s ${davinci}/lib/udev/rules.d/99-BlackmagicDevices.rules $out/lib/udev/rules.d/
      ln -s ${davinci}/lib/udev/rules.d/99-ResolveKeyboardHID.rules $out/lib/udev/rules.d/
      ln -s ${davinci}/lib/udev/rules.d/99-DavinciPanel.rules $out/lib/udev/rules.d/
    '';

  passthru = {
    inherit davinci;
  }
  // lib.optionalAttrs (!studioVariant) {
    updateScript = lib.getExe (writeShellApplication {
      name = "update-davinci-resolve";
      runtimeInputs = [
        curl
        jq
        common-updater-scripts
      ];
      text = ''
        set -o errexit
        drv=pkgs/by-name/da/davinci-resolve/package.nix
        currentVersion=${lib.escapeShellArg davinci.version}
        downloadsJSON="$(curl --fail --silent https://www.blackmagicdesign.com/api/support/us/downloads.json)"

        latestLinuxVersion="$(echo "$downloadsJSON" | jq '[.downloads[] | select(.urls.Linux) | .urls.Linux[] | select(.downloadTitle | test("DaVinci Resolve")) | .downloadTitle]' | grep -oP 'DaVinci Resolve \K\d+\.\d+(\.\d+)?' | sort | tail -n 1)"
        update-source-version davinci-resolve "$latestLinuxVersion" --source-key=davinci.src

        # Since the standard and studio both use the same version we need to reset it before updating studio
        sed -i -e "s/""$latestLinuxVersion""/""$currentVersion""/" "$drv"

        latestStudioLinuxVersion="$(echo "$downloadsJSON" | jq '[.downloads[] | select(.urls.Linux) | .urls.Linux[] | select(.downloadTitle | test("DaVinci Resolve")) | .downloadTitle]' | grep -oP 'DaVinci Resolve Studio \K\d+\.\d+(\.\d+)?' | sort | tail -n 1)"
        update-source-version davinci-resolve-studio "$latestStudioLinuxVersion" --source-key=davinci.src
      '';
    });
  };

  inherit (davinci) meta;
}
