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

  nativeBuildInputs = [ cmake ];

  buildInputs = [ ffmpeg-full ];

  installPhase =
    let
      plugin = "ffmpeg_encoder_plugin.dvcp";
    in
    ''
      runHook preInstall
      mkdir -p $out/${plugin}.bundle/Contents/Linux-x86-64
      cp ${plugin} $out/${plugin}.bundle/Contents/Linux-x86-64/
      runHook postInstall
    '';
})
