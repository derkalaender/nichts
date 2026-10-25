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
        in
        with pkgs;
        [
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
