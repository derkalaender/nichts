{
  stdenv,
  fetchFromGitHub,
  ffmpeg-full,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "aac-encoder-plugin";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "Toxblh";
    repo = "davinci-linux-aac-codec";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-NVNxmUFNwZ3hzlyi3QVENXhfPICAAP3M4s6QEgWsP/g=";
  };

  buildInputs = [ffmpeg-full];

  # Don't use clang and patch out hardcoded paths and flags
  postPatch = ''
    substituteInPlace .mk.defs \
      --replace "CC = clang++" "CC = c++"
    substituteInPlace Makefile \
      --replace " -I/usr/include/c++/14" "" \
      --replace " -stdlib=libstdc++" "" \
      --replace " -I/usr/include/c++/x86_64-redhat-linux/14" ""
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/aac_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64
    cp bin/aac_encoder_plugin.dvcp $out/aac_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64/
    runHook postInstall
  '';
})
