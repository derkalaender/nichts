{
  fetchFromGitHub,
  llvmPackages,
  pkg-config,
  fdk_aac,
}:
llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "aac-fdk-encoder-plugin";
  version = "64fe082fa1fa9b725d7f4ca22b1d76016bb3e527";

  src = fetchFromGitHub {
    owner = "hexitnz";
    repo = "Resolve-Linux-Studio-AAC-FDK-Encoder-plugin";
    rev = finalAttrs.version;
    sha256 = "sha256-jQszdeJfkcg7djJh5Dt5w19IlEeJTm+GciyL5RSYecM=";
  };

  sourceRoot = "${finalAttrs.src.name}/src";

  nativeBuildInputs = [pkg-config];
  buildInputs = [llvmPackages.libcxx fdk_aac];

  installPhase = let
    plugin = "aac_fdk_plugin.dvcp";
  in ''
    runHook preInstall
    mkdir -p $out/${plugin}.bundle/Contents/Linux-x86-64
    cp bin/${plugin} $out/${plugin}.bundle/Contents/Linux-x86-64/
    runHook postInstall
  '';
})
