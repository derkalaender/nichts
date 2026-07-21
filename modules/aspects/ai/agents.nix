{inputs, ...}: {
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  nichts.aspects.llm-agents.homeManager = {pkgs, ...}: {
    home.packages = let
      llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
      with pkgs; [
        llm-agents.pi
        llm-agents.agent-browser
        pnpm
        nodejs
        python3
        go
        delta
        glow
      ];
  };
}
