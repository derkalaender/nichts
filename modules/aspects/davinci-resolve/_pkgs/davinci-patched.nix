# https://www.reddit.com/r/LinuxCrackSupport/comments/1nfqhld/davinci_resolve_studio_202_fix_linux_crack_guide/
{
  writers,
  writeTextDir,
  symlinkJoin,
  davinci-resolve-studio-unwrapped,
  davinci-resolve-studio,
  ffmpeg-encoder-plugin,
  aac-encoder-plugin,
  aac-fdk-encoder-plugin,
}: let
  wrapped = davinci-resolve-studio;
  unwrapped = davinci-resolve-studio-unwrapped;
  patcher =
    writers.writePython3Bin "patcher"
    {
      flakeIgnore = [
        "E111" # Indentation is not a multiple of 4.
        "E121" # Continuation line under-indented for hanging indent.
        "E241" # Multiple spaces after ':'.
        "E501" # Line too long.
      ];
    }
    ''
      import sys

      target = sys.argv[1]
      data = open(target, "rb").read()

      patches = [
        {
          "find":    "03008945FC837DFC007411488B45C88B",
          "replace": "03008945FC837DFC00EB11488B45C88B"
        },
        {
          "find":    "7411488B45C88B55FC895058B8000000",
          "replace": "EB11488B45C88B55FC895058B8000000"
        },
        {
          "find":    "41B60184C00F84B000000048 85DB74084531F6E9A3000000".replace(" ", ""),
          "replace": "41B60084C00F84B000000048 85DB74084531F6E9A3000000".replace(" ", "")
        }
      ]

      for p in patches:
        find_bytes = bytes.fromhex(p["find"])
        replace_bytes = bytes.fromhex(p["replace"])

        count = data.count(find_bytes)
        assert count > 0, f"pattern {p['find']} not found in {target}"

        data = data.replace(find_bytes, replace_bytes)

      open(target, "wb").write(data)
      print(f"patched {target} successfully")
    '';
  licenseDir = writeTextDir "blackmagic.lic" ''
    LICENSE blackmagic davinciresolvestudio 999999 permanent uncounted
      hostid=ANY issuer=CGP customer=CGP issued=28-dec-2023
      akey=0000-0000-0000-0000 _ck=00 sig="00"
  '';
  iopluginsDir = symlinkJoin {
    name = "davinci-resolve-ioplugins";
    paths = [
      ffmpeg-encoder-plugin
      aac-encoder-plugin
      aac-fdk-encoder-plugin
    ];
  };
  patchedDavinci = symlinkJoin {
    inherit (wrapped) pname version;
    paths = [unwrapped];
    nativeBuildInputs = [patcher];
    postBuild = ''
      # Replace resolve binary with patched version
      rm -f $out/bin/resolve
      install -m755 ${unwrapped}/bin/resolve $out/bin/resolve
      patcher $out/bin/resolve

      # Symlink license directory
      rm -rf $out/.license
      ln -s ${licenseDir} $out/.license

      # Symlink IOPlugins directory
      rm -rf $out/IOPlugins
      ln -s ${iopluginsDir} $out/IOPlugins
    '';
  };
in
  wrapped.override {
    davinci-resolve-unwrapped = patchedDavinci;
  }
