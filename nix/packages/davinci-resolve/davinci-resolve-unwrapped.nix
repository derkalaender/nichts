# https://github.com/NixOS/nixpkgs/blob/64c08a7ca051951c8eae34e3e3cb1e202fe36786/pkgs/by-name/da/davinci-resolve/package.nix
{
  stdenv,
  lib,
  cacert,
  curl,
  runCommandLocal,
  unzip,
  appimageTools,
  addDriverRunpath,
  libGLU,
  libxxf86vm,
  makeDesktopItem,
  copyDesktopItems,
  jq,
  studioVariant ? false,
}:
stdenv.mkDerivation rec {
  pname = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
  version = "20.3.2";

  nativeBuildInputs = [
    appimageTools.appimage-exec
    addDriverRunpath
    copyDesktopItems
    unzip
  ];

  # Pretty sure, there are missing dependencies ...
  buildInputs = [
    libGLU
    libxxf86vm
  ];

  src =
    runCommandLocal "${pname}-src.zip"
      rec {
        outputHashMode = "recursive";
        outputHashAlgo = "sha256";
        outputHash =
          if studioVariant then
            "sha256-wUrx/cMIyMI+sYi8n8xHH4Q7c0MSAoGbpI0E1NtzcXg="
          else
            "sha256-q3/QFUFmTuToIhc+r9L5/DCqpRjbLfECVxhlburly7M=";

        impureEnvVars = lib.fetchers.proxyImpureEnvVars;

        nativeBuildInputs = [
          curl
          jq
        ];

        # ENV VARS
        SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

        # Get linux.downloadId from HTTP response on https://www.blackmagicdesign.com/products/davinciresolve
        REFERID = "263d62f31cbb49e0868005059abcb0c9";
        DOWNLOADSURL = "https://www.blackmagicdesign.com/api/support/us/downloads.json";
        SITEURL = "https://www.blackmagicdesign.com/api/register/us/download";
        PRODUCT = "DaVinci Resolve${lib.optionalString studioVariant " Studio"}";
        VERSION = version;

        USERAGENT = builtins.concatStringsSep " " [
          "User-Agent: Mozilla/5.0 (X11; Linux ${stdenv.hostPlatform.linuxArch})"
          "AppleWebKit/537.36 (KHTML, like Gecko)"
          "Chrome/77.0.3865.75"
          "Safari/537.36"
        ];

        REQJSON = builtins.toJSON {
          "firstname" = "NixOS";
          "lastname" = "Linux";
          "email" = "someone@nixos.org";
          "phone" = "+31 71 452 5670";
          "country" = "nl";
          "street" = "-";
          "state" = "Province of Utrecht";
          "city" = "Utrecht";
          "product" = PRODUCT;
        };
      }
      ''
        DOWNLOADID=$(
          curl --silent --compressed "$DOWNLOADSURL" \
            | jq --raw-output '.downloads[] | .urls.Linux?[]? | select(.downloadTitle | test("^'"$PRODUCT $VERSION"'( Update)?$")) | .downloadId'
        )
        echo "downloadid is $DOWNLOADID"
        test -n "$DOWNLOADID"
        RESOLVEURL=$(curl \
          --silent \
          --header 'Host: www.blackmagicdesign.com' \
          --header 'Accept: application/json, text/plain, */*' \
          --header 'Origin: https://www.blackmagicdesign.com' \
          --header "$USERAGENT" \
          --header 'Content-Type: application/json;charset=UTF-8' \
          --header "Referer: https://www.blackmagicdesign.com/support/download/$REFERID/Linux" \
          --header 'Accept-Encoding: gzip, deflate, br' \
          --header 'Accept-Language: en-US,en;q=0.9' \
          --header 'Authority: www.blackmagicdesign.com' \
          --header 'Cookie: _ga=GA1.2.1849503966.1518103294; _gid=GA1.2.953840595.1518103294' \
          --data-ascii "$REQJSON" \
          --compressed \
          "$SITEURL/$DOWNLOADID")
        echo "resolveurl is $RESOLVEURL"

        curl \
          --retry 3 --retry-delay 3 \
          --header "Upgrade-Insecure-Requests: 1" \
          --header "$USERAGENT" \
          --header "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" \
          --header "Accept-Language: en-US,en;q=0.9" \
          --compressed \
          "$RESOLVEURL" \
          > $out
      '';

  # The unpack phase won't generate a directory
  sourceRoot = ".";

  installPhase =
    let
      appimageName = "DaVinci_Resolve_${lib.optionalString studioVariant "Studio_"}${version}_Linux.run";
    in
    ''
      runHook preInstall

      export HOME=$PWD/home
      mkdir -p $HOME

      mkdir -p $out
      test -e ${lib.escapeShellArg appimageName}
      appimage-exec.sh -x $out ${lib.escapeShellArg appimageName}

      mkdir -p $out/{"Apple Immersive/Calibration",configs,DolbyVision,easyDCP,Extras,Fairlight,GPUCache,logs,Media,"Resolve Disk Database",.crashreport,.license,.LUT}

      # Install udev rules for Blackmagic hardware (color panels, Speed Editor, Editor Keyboard)
      mkdir -p $out/lib/udev/rules.d
      cp $out/share/etc/udev/rules.d/99-BlackmagicDevices.rules $out/lib/udev/rules.d/
      cp $out/share/etc/udev/rules.d/99-ResolveKeyboardHID.rules $out/lib/udev/rules.d/
      # Generate catch-all rules for Blackmagic Design vendor ID (096e)
      # USB device access (color panels, general hardware)
      echo 'SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="096e", MODE="0666"' \
        > $out/lib/udev/rules.d/99-DavinciPanel.rules
      # hidraw access (Speed Editor jog wheel, Editor Keyboard, future HID devices)
      echo 'KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="096e", MODE="0666"' \
        >> $out/lib/udev/rules.d/99-DavinciPanel.rules

      # Verify all three rules files are present
      test -f $out/lib/udev/rules.d/99-BlackmagicDevices.rules
      test -f $out/lib/udev/rules.d/99-ResolveKeyboardHID.rules
      test -f $out/lib/udev/rules.d/99-DavinciPanel.rules
      runHook postInstall
    '';

  dontStrip = true;

  postFixup = ''
    for program in $out/bin/*; do
      isELF "$program" || continue
      addDriverRunpath "$program"
    done

    for program in $out/libs/*; do
      isELF "$program" || continue
      if [[ "$program" != *"libcudnn_cnn_infer"* ]];then
        echo $program
        addDriverRunpath "$program"
      fi
    done
    ln -s $out/libs/libcrypto.so.1.1 $out/libs/libcrypt.so.1
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      desktopName = "Davinci Resolve${lib.optionalString studioVariant " Studio"}";
      genericName = "Video Editor";
      exec = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      icon = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      comment = "Professional video editing, color, effects and audio post-processing";
      categories = [
        "AudioVideo"
        "AudioVideoEditing"
        "Video"
        "Graphics"
      ];
      startupWMClass = "resolve";
    })
    (makeDesktopItem {
      name = "blackmagicraw-player";
      desktopName = "Blackmagic RAW Player";
      exec = "blackmagicraw-player %f";
      icon = "blackmagicraw-player";
      mimeTypes = [
        "application/x-braw-clip"
        "application/x-braw-sidecar"
      ];
      categories = [
        "Video"
        "AudioVideo"
      ];
    })
    (makeDesktopItem {
      name = "blackmagicraw-speedtest";
      desktopName = "Blackmagic RAW Speed Test";
      exec = "blackmagicraw-speedtest";
      icon = "blackmagicraw-speedtest";
      categories = [
        "Video"
        "AudioVideo"
      ];
    })
    (makeDesktopItem {
      name = "davinci-control-panels-setup";
      desktopName = "DaVinci Control Panels Setup";
      exec = "davinci-control-panels-setup";
      icon = "davinci-control-panels-setup";
      categories = [ "Settings" ];
    })
    (makeDesktopItem {
      name = "davinci-fairlight-studio-utility";
      desktopName = "Fairlight Studio Utility";
      exec = "davinci-fairlight-studio-utility";
      icon = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
      categories = [
        "AudioVideo"
        "Audio"
      ];
    })
  ]
  ++ lib.optional studioVariant (makeDesktopItem {
    name = "davinci-remote-monitor";
    desktopName = "DaVinci Remote Monitor";
    exec = "davinci-remote-monitor";
    icon = "davinci-remote-monitor";
    comment = "DaVinci Remote Monitor";
    categories = [
      "AudioVideo"
      "Video"
    ];
  });

  meta = {
    description = "Professional video editing, color, effects and audio post-processing";
    homepage = "https://www.blackmagicdesign.com/products/davinciresolve";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      amarshall
      XBagon
      toXel
      cafkafk
    ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "davinci-resolve${lib.optionalString studioVariant "-studio"}";
  };
}
