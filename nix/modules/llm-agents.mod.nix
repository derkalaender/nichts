{ inputs, ... }: {
  nichts.modules.llm-agents.home =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages =
        let
          llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
          tools = with pkgs; [
            # vcs / review
            gh
            git

            # cli utilities the agent shells out to
            coreutils
            findutils
            file
            gnugrep
            gnused
            gawk
            curl
            wget
            ripgrep
            fd
            jq
            yq
            zip
            unzip
            gnutar
            sqlite
            patch
            diffutils
            lsof
            procps
            strace
            openssl
            treefmt
            sops
            age
            just

            # languages
            bash
            shellcheck
            rustc
            cargo
            rust-analyzer
            gcc
            gnumake
            cmake
            ninja
            pkg-config
            meson
            buck2
            clang-tools
            go
            gopls
            nodejs
            pnpm
            prettier
            typescript
            typescript-language-server
            svelte-language-server
            python3
            uv
            basedpyright
            ruff

            # nix
            nix
            nixfmt
            nix-index
            nil
            nixd
            nh
            dix
          ];
          omp = pkgs.symlinkJoin {
            name = "omp";
            paths = [ llm-agents.omp ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/omp --suffix PATH : ${lib.makeBinPath tools}
            '';
          };
        in
        [ omp ];
    };
}
