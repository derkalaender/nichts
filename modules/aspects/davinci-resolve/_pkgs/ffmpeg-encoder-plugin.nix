{
  stdenv,
  fetchFromGitHub,
  cmake,
  ffmpeg-full,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ffmpeg-encoder-plugin";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "EdvinNilsson";
    repo = "ffmpeg_encoder_plugin";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-uaTxUmP3I3/MLkYKHikhCGSC9OCoiIfnIBnBUm8qif8=";
  };

  nativeBuildInputs = [cmake];

  buildInputs = [ffmpeg-full];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/ffmpeg_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64
    cp ffmpeg_encoder_plugin.dvcp $out/ffmpeg_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64/
    runHook postInstall
  '';
})
