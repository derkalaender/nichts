{
  stdenvNoCC,
  makeWrapper,
  patchelf,
  lib,
  llm-agents,
  llmPkgs,
}:
# Wrap omp so its native addon resolves libraries by DT_RUNPATH, not LD_LIBRARY_PATH.
stdenvNoCC.mkDerivation {
  name = "omp-${llm-agents.omp.version}";
  nativeBuildInputs = [
    makeWrapper
    patchelf
  ];
  dontUnpack = true; # no src; unpackPhase errors otherwise
  # 380 MB of prebuilt Bun output: leave its ELF loader and sections alone.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    mkdir -p $out/lib/omp $out/bin
    cp -a ${llm-agents.omp}/lib/omp/. $out/lib/omp
    chmod -R u+w $out/lib/omp
    patchelf --set-rpath ${
      lib.makeLibraryPath (
        with llmPkgs;
        [
          zlib
          stdenv.cc.cc.lib
          libpulseaudio
          pipewire
        ]
      )
    } \
      $out/lib/omp/omp $out/lib/omp/pi_natives.*.node
    makeWrapper $out/lib/omp/omp $out/bin/omp --set PI_SKIP_VERSION_CHECK 1
  '';
}
