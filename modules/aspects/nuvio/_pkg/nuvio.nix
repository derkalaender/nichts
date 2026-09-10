# Nuvio (NuvioDesktop) — Compose Desktop media app, built from source.
#
# Uses the nixpkgs Gradle packaging pattern (mitmCache + fetchDeps):
# dependencies are recorded into pkgs/deps.json by the generated update
# script, and builds are served deterministically from that lockfile.
#
# The jpackage launcher binary is replaced by a plain script that execs a
# full JDK directly: jlink-trimmed runtimes ship no `java` binary and the
# jpackage launcher resets LD_LIBRARY_PATH, which cannot work on NixOS.
# Classpath and JVM options are parsed from the generated Nuvio.cfg.
{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  gradle_9,
  temurin-bin-17,
  temurin-bin-21,
  cmake,
  pkg-config,
  desktop-file-utils,
  # Native Linux video player (JNI) compiles against GStreamer headers;
  # plugin sets are needed at playback runtime.
  gst_all_1,
  # Linux player bridge (JNI) links against system libmpv + WebKitGTK.
  mpv,
  webkitgtk_4_1,
  libxcomposite,
  # Libraries linked by the bundled AWT/Skiko natives at runtime:
  gtk3,
  glib,
  libglvnd,
  libx11,
  libxext,
  libxrender,
  libxtst,
  libxi,
  libxcursor,
  fontconfig,
  freetype,
  xdg-utils,
}: let
  version = "0.1.21-alpha";

  # Upstream pins jvmToolchain(17) in vendored compose-media-player;
  # JDK 21 launches Gradle and serves as the packaged runtime.
  jdk17 = temurin-bin-17;
  jdk21 = temurin-bin-21;

  gstPlugins = with gst_all_1; [
    gstreamer.out
    gst-plugins-base.out
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];

  runtimeLibs = [
    gtk3
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
    stdenv.cc.cc.lib # libstdc++ required by libskiko
    mpv
    webkitgtk_4_1
  ];
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "nuvio";
    inherit version;

    src = fetchFromGitHub {
      owner = "NuvioMedia";
      repo = "NuvioDesktop";
      rev = version;
      hash = "sha256-12TQYCon+atu0+V/xyGuaqX7UfrsTQXkHp6UZqVpB1Y=";
    };

    # Records every Maven artifact Gradle fetches into pkgs/deps.json.
    # Refresh after an upstream bump with:
    #   nix build .#nuvio.mitmCache.updateScript && ./result
    # The bwrap bind is required because gnumake hardcodes /bin/sh, which
    # the minimal update-script sandbox does not contain.
    mitmCache = gradle_9.fetchDeps {
      pkg = finalAttrs.finalPackage;
      data = ./deps.json;
      bwrapFlags = "--ro-bind /bin/sh /bin/sh";
    };

    # Baked-in defaults extracted from the official 0.1.20-alpha desktop
    # build (values are client-side constants shipped in every official
    # binary). See postPatch for how these become runtime-overridable via
    # env vars.
    env.NUVIO_SUPABASE_URL = "https://api.nuvio.tv";
    env.NUVIO_SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlzcyI6InN1cGFiYXNlIiwiaWF0IjoxNzgxNTIxMzQ2LCJleHAiOjE5MzkyMDEzNDZ9.tmQaj682pwzehpqlgCDMnySOqiUvpgRbrE43T4VJpDI";
    env.NUVIO_SUPABASE_FALLBACK_URL = "https://api-two.nuvioapp.space";

    postPatch = ''
          # Upstream's generateRuntimeConfigs declares local.properties as an
          # input file; an empty one keeps defaults (env vars still override).
          test -f local.properties || touch local.properties

          # Credentials/URLs the official builds bake in (extracted from the
          # 0.1.20-alpha desktop jar; identical values ship in the mobile APK).
          # generateRuntimeConfigs reads these at build time; the getter patches
          # below additionally allow env-var overrides at runtime.
          cat >> local.properties <<'EOF'
      TRAKT_CLIENT_ID=5783db7c46a5b22f072d4b224f9bd7dc2cbaba66dbe3515d1feb59e3ca72394c
      TRAKT_CLIENT_SECRET=bf6e7561dafee902f5a2a67d2b31feac1563632f331f3958c978aff6389ea384
      SIMKL_CLIENT_ID=dc20e0db975583b15096267cee79cd23b1f56d4bd301ce3c51e4a96a49c834a6
      INTRODB_API_URL=https://api.introdb.app/
      IMDB_RATINGS_API_BASE_URL=https://seriesgraph.com/
      IMDB_TAPFRAME_API_BASE_URL=https://imdb.tapframe.space/
      EOF

          # Upstream bakes Supabase endpoints as compile-time constants. Turn
          # them into getters that prefer env vars at runtime, falling back to
          # the values baked at build time above.
          substituteInPlace composeApp/build.gradle.kts \
            --replace-fail 'const val URL = "''${supabaseUrl.get()}"' \
                           'val URL: String get() = System.getenv("NUVIO_SUPABASE_URL") ?: "''${supabaseUrl.get()}"' \
            --replace-fail 'const val ANON_KEY = "''${supabaseAnonKey.get()}"' \
                           'val ANON_KEY: String get() = System.getenv("NUVIO_SUPABASE_ANON_KEY") ?: "''${supabaseAnonKey.get()}"' \
            --replace-fail 'const val FALLBACK_URL = "''${supabaseFallbackUrl.get()}"' \
                           'val FALLBACK_URL: String get() = System.getenv("NUVIO_SUPABASE_FALLBACK_URL") ?: "''${supabaseFallbackUrl.get()}"' \
            --replace-fail 'const val CLIENT_ID = "''${props.getProperty("TRAKT_CLIENT_ID", "")}"' \
                           'val CLIENT_ID: String get() = System.getenv("TRAKT_CLIENT_ID") ?: "''${props.getProperty("TRAKT_CLIENT_ID", "")}"' \
            --replace-fail 'const val CLIENT_SECRET = "''${props.getProperty("TRAKT_CLIENT_SECRET", "")}"' \
                           'val CLIENT_SECRET: String get() = System.getenv("TRAKT_CLIENT_SECRET") ?: "''${props.getProperty("TRAKT_CLIENT_SECRET", "")}"' \
            --replace-fail 'const val CLIENT_ID = "''${props.getProperty("SIMKL_CLIENT_ID", "")}"' \
                           'val CLIENT_ID: String get() = System.getenv("SIMKL_CLIENT_ID") ?: "''${props.getProperty("SIMKL_CLIENT_ID", "")}"'

          # Upstream hides the external-player option on desktop even though a
          # full implementation exists (ExternalPlayerPlatform.desktop.kt opens
          # stream URLs via java.awt.Desktop / xdg-open). Expose it: with in-app
          # playback unimplemented on Linux this is the only way to watch.
          substituteInPlace \
            composeApp/src/desktopMain/kotlin/com/nuvio/app/core/build/AppFeaturePolicy.desktop.kt \
            --replace-fail 'actual val externalPlayerSupported: Boolean = false' \
                           'actual val externalPlayerSupported: Boolean = true'
    '';

    gradleFlags = [
      "--console=plain"
      "--no-configuration-cache"
      "-Dorg.gradle.java.installations.paths=${jdk17},${jdk21}"
      "-Dorg.gradle.java.installations.auto-download=false"
    ];
    gradleBuildTask = ":composeApp:createReleaseDistributable";
    gradleUpdateTask = ":composeApp:createReleaseDistributable";

    # cmake is on PATH only (gradle's buildNativeLinux invokes it); the
    # setup hook must not try to configure this non-cmake project.
    dontUseCmakeConfigure = true;

    nativeBuildInputs = [
      gradle_9
      makeWrapper
      jdk21
      cmake
      pkg-config
      copyDesktopItems
      desktop-file-utils
    ];
    buildInputs = [
      glib
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      # buildLinuxPlayerBridge compiles against these via pkg-config
      mpv
      webkitgtk_4_1
      gtk3
      libx11
      libxcomposite
      libxext
    ];

    # Installs the hicolor icon; the .desktop entry itself is generated via
    # desktopItems/copyDesktopItems. URL schemes mirror what upstream
    # registers on macOS (nuvio://, stremio://). WM_CLASS measured from a
    # live window: raw-java launches register com-nuvio-app-MainKt, not the
    # package name. Icon file name verified against the 0.1.20-alpha tag
    # (main branch renamed it to *-transparent.png).
    postInstall = ''
      install -Dm644 composeApp/src/desktopMain/resources/icons/nuvio-app-icon-transparent.png \
        $out/share/icons/hicolor/256x256/apps/nuvio.png
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "nuvio";
        desktopName = "Nuvio";
        genericName = "Media Center";
        comment = "Browse, organize, and play media from your sources";
        exec = "nuvio";
        tryExec = "nuvio";
        icon = "nuvio";
        terminal = false;
        categories = ["AudioVideo" "Video"];
        mimeTypes = [
          "x-scheme-handler/nuvio"
          "x-scheme-handler/stremio"
        ];
        startupWMClass = "com-nuvio-app-MainKt";
      })
    ];
    # Launcher: pkgs/launcher.sh template + values parsed from the
    # jpackage-generated Nuvio.cfg (classpath, JVM options, main class).
    installPhase = ''
      runHook preInstall

      appImage=$(find composeApp/build/compose/binaries -type d -name Nuvio | head -1)
      test -n "$appImage" || { echo "app image not found"; exit 1; }

      mkdir -p $out/share/nuvio $out/bin
      cp -r "$appImage"/lib/app $out/share/nuvio/lib-app

      export appDir=$out/share/nuvio/lib-app
      export ldLibraryPath=${lib.makeLibraryPath runtimeLibs}
      export gstPluginPath=${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}
      export extraPath=${lib.makeBinPath [xdg-utils]}
      export jdk=${jdk21}
      export classpath=$(sed -n "s|^app.classpath=\$APPDIR|$appDir|p" "$appImage/lib/app/Nuvio.cfg" | paste -sd:)
      export javaOptions=$(sed -n 's/^java-options=//p' "$appImage/lib/app/Nuvio.cfg" \
        | grep -v 'sun.lwawt.macosx\|sun.awt.windows\|apple.awt' \
        | sed "s|\$APPDIR|$appDir|g" | paste -sd' ')
      export mainClass=$(sed -n 's/^app.mainclass=//p' "$appImage/lib/app/Nuvio.cfg")

      substituteAll ${./launcher.sh} $out/bin/nuvio
      chmod +x $out/bin/nuvio

      runHook postInstall
    '';

    # Smoke check: launcher fully substituted, desktop entry valid, icon in
    # the hicolor path. The placeholder grep catches substituteAll silently
    # skipping a variable (regression guard: this shipped once).
    installCheckPhase = ''
      test -x $out/bin/nuvio
      test -f $out/share/nuvio/lib-app/Nuvio.cfg
      bash -n $out/bin/nuvio
      ! grep -qE '@[A-Za-z][A-Za-z0-9_]*@' $out/bin/nuvio
      desktop-file-validate $out/share/applications/nuvio.desktop
      test -f $out/share/icons/hicolor/256x256/apps/nuvio.png
    '';
    doInstallCheck = true;

    passthru = {
      jdk = jdk21;
    };

    meta = {
      description = "Nuvio desktop media client";
      homepage = "https://github.com/NuvioMedia/NuvioDesktop";
      license = lib.licenses.gpl3Only;
      mainProgram = "nuvio";
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryBytecode # mitm cache
      ];
    };
  })
