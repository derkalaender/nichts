{inputs, ...}: {
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  nichts.aspects.llm-agents.homeManager = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

      # llm-agents exports LD_LIBRARY_PATH so omp's native addon finds
      # libpipewire/libpulse/libz/libgcc_s. Children inherit it, and its
      # gcc-15.3.0-lib entry shadows libstdc++: `nix` run from omp then dies with
      # "GLIBCXX_3.4.36 not found (required by liblix.so)". Same paths, but in
      # DT_RUNPATH: read from the file, invisible to children. Delete this once
      # upstream stops exporting the variable.
      # The libs come from llm-agents' own nixpkgs: omp's binaries run against
      # its glibc 2.42, ours is 2.44 and mixing the two fails to load.
      llmPkgs = inputs.llm-agents.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

      omp = pkgs.stdenvNoCC.mkDerivation {
        name = "omp-${llm-agents.omp.version}";
        nativeBuildInputs = [pkgs.makeWrapper pkgs.patchelf];
        dontUnpack = true; # no src; unpackPhase errors otherwise
        # 380 MB of prebuilt Bun output: leave its ELF loader and sections alone.
        dontStrip = true;
        dontPatchELF = true;

        installPhase = ''
          mkdir -p $out/lib/omp $out/bin
          cp -a ${llm-agents.omp}/lib/omp/. $out/lib/omp
          chmod -R u+w $out/lib/omp
          patchelf --set-rpath ${lib.makeLibraryPath (with llmPkgs; [zlib stdenv.cc.cc.lib libpulseaudio pipewire])} \
            $out/lib/omp/omp $out/lib/omp/pi_natives.*.node
          makeWrapper $out/lib/omp/omp $out/bin/omp --set PI_SKIP_VERSION_CHECK 1
        '';

        # No LD_LIBRARY_PATH here, so this fails unless the RPATH resolves every
        # library: the smoke test covers DT_NEEDED, bun:ffi the dlopen'd ones.
        doInstallCheck = true;
        installCheckPhase = ''
          HOME=$TMPDIR $out/bin/omp --smoke-test | grep -q "smoke-test: ok"
          HOME=$TMPDIR BUN_BE_BUN=1 $out/lib/omp/omp -e 'const {dlopen} = require("bun:ffi"); for (const [n, s] of [["libpulse.so.0", {pa_strerror: {args: ["int"], returns: "cstring"}}], ["libpipewire-0.3.so.0", {pw_init: {args: ["ptr", "ptr"], returns: "void"}}], ["libz.so.1", {zlibVersion: {args: [], returns: "cstring"}}]]) dlopen(n, s);'
        '';
      };
    in
      with pkgs; [
        # agent
        omp
        llm-agents.agent-browser

        # vcs / review
        delta
        gh

        # cli utilities the agent shells out to
        fd
        glow
        jq
        ripgrep
        yq

        # language runtimes
        gcc
        go
        nodejs
        pnpm
        python3

        # language servers
        clang-tools # clangd (C/C++)
        gopls # Go
        nil
        nixd
        svelte-language-server # Svelte
        typescript # peer dep for tsserver
        typescript-language-server # JS/TS
        pyright # Python
        rust-analyzer # Rust
      ];
  };
}
