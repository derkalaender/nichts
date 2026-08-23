{...}: {
  nichts.aspects.blender.homeManager = {pkgs, ...}: {
    home.packages = [
      (
        pkgs.pkgsRocm.blender.override {
          waylandSupport = true;
        }
      )
      # (pkgs.symlinkJoin {
      #   name = "blender-wrapped";
      #   paths = [
      #     (pkgs.pkgsRocm.blender.override {
      #       waylandSupport = true;
      #     })
      #   ];
      #   buildInputs = [pkgs.makeWrapper];
      #   postBuild = ''
      #     wrapProgram $out/bin/blender \
      #       --set LD_PRELOAD "${pkgs.rocmPackages.rocm-comgr}/lib/libamd_comgr.so.3" \
      #   '';
      # })
      # (pkgs.pkgsRocm.blender.overrideAttrs (old: {
      #   # Disable OSL entirely to avoid the LLVM ABI mismatch between
      #   # libamd_comgr's internal LLVM and openshadinglanguage's LLVM.
      #   # See https://github.com/nixos/nixpkgs/issues/508671
      #   # TODO: Remove once https://github.com/NixOS/nixpkgs/pull/514285 is merged
      #   #       and the upstream fix handles pkgsRocm correctly.
      #   cmakeFlags =
      #     builtins.filter
      #     (f: builtins.isString f -> builtins.match ".*WITH_CYCLES_OSL.*" f == null)
      #     old.cmakeFlags
      #     ++ [(pkgs.lib.cmakeBool "WITH_CYCLES_OSL" false)];

      #   buildInputs =
      #     builtins.filter
      #     (p: p != pkgs.pkgsRocm.python313Packages.openshadinglanguage)
      #     old.buildInputs;

      #   pythonPath =
      #     builtins.filter
      #     (p: p != pkgs.pkgsRocm.python313Packages.openshadinglanguage)
      #     old.pythonPath;
      # }))
    ];
  };
}
