# Nuvio (NuvioDesktop) — packaged from the upstream release AppImage.
#
# The AppImage is a jpackage app image: an ELF launcher, a jlink-trimmed
# JDK 17 runtime and the application jars. It carries no host libraries, so
# the wrapper puts them on LD_LIBRARY_PATH: Skiko/AWT want GTK, X11 and
# fontconfig, and the JNI bridges (libplayer_bridge, libNativeVideoPlayer,
# libnuvio_engine) want mpv, WebKitGTK, GStreamer and libstdc++.
#
# We exec the launcher ELF instead of the AppImage's AppRun: AppRun only
# execs the same binary, but it drags in /usr/bin/env and a PATH lookup.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  desktop-file-utils,
  # Skiko/AWT natives and the JNI player bridges link against these.
  gtk3,
  cairo,
  glib,
  libglvnd,
  libx11,
  libxext,
  libxrender,
  libxtst,
  libxi,
  libxcursor,
  libxcomposite,
  fontconfig,
  freetype,
  mpv,
  webkitgtk_4_1,
  # GStreamer plugins are dlopen'd at playback time, not linked.
  gst_all_1,
  xdg-utils,
}:
let
  pname = "nuvio";
  version = "0.1.29-alpha";

  src = fetchurl {
    url = "https://github.com/NuvioMedia/NuvioDesktop/releases/download/${version}/Nuvio-Linux-x86_64-${version}.AppImage";
    hash = "sha256-rQoMR+tWVqu0VHA2G7Oj39HwuzxO+KP3snJYyW87GsI=";
  };

  contents = appimageTools.extract { inherit pname version src; };

  gstPlugins = with gst_all_1; [
    gstreamer.out
    gst-plugins-base.out
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];

  runtimeLibs = [
    gtk3
    cairo
    glib
    libglvnd
    libx11
    libxext
    libxrender
    libxtst
    libxi
    libxcursor
    libxcomposite
    fontconfig
    freetype
    stdenv.cc.cc.lib # libstdc++ for libskiko and the bridges
    mpv
    webkitgtk_4_1
  ];
in
stdenvNoCC.mkDerivation {
  inherit pname version src;

  # The AppImage is already an unpacked application tree.
  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    desktop-file-utils
  ];

  # Mirrors the desktop entry upstream ships in the AppImage; the URL
  # schemes are the ones the app registers for itself on Linux.
  desktopItems = [
    (makeDesktopItem {
      name = "nuvio";
      desktopName = "Nuvio";
      genericName = "Media Center";
      comment = "Browse, organize, and play media from your sources";
      exec = "nuvio %u";
      tryExec = "nuvio";
      icon = "nuvio";
      terminal = false;
      categories = [
        "AudioVideo"
        "Video"
      ];
      mimeTypes = [
        "x-scheme-handler/nuvio"
        "x-scheme-handler/stremio"
      ];
      startupWMClass = "com-nuvio-app-MainKt";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${contents}/bin/Nuvio $out/bin/nuvio \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}" \
      --prefix GST_PLUGIN_SYSTEM_PATH : "${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}" \
      --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}"

    install -Dm644 ${contents}/lib/Nuvio.png \
      $out/share/icons/hicolor/256x256/apps/nuvio.png

    runHook postInstall
  '';

  # Smoke check: the wrapper runs the jpackage launcher, the launcher
  # finds its config next to it, and the desktop entry is valid.
  installCheckPhase = ''
    test -x $out/bin/nuvio
    test -x ${contents}/bin/Nuvio
    grep -q '^app.mainclass=com.nuvio.app.MainKt$' ${contents}/lib/app/Nuvio.cfg
    desktop-file-validate $out/share/applications/nuvio.desktop
    test -f $out/share/icons/hicolor/256x256/apps/nuvio.png
  '';
  doInstallCheck = true;

  meta = {
    description = "Nuvio desktop media client";
    homepage = "https://github.com/NuvioMedia/NuvioDesktop";
    license = lib.licenses.gpl3Only;
    mainProgram = "nuvio";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
