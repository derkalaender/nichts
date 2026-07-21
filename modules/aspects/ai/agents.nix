{inputs, ...}: {
  flake-file.inputs = {
    llm-agents.url = "github:numtide/llm-agents.nix";
  };
  nichts.overlays = [inputs.llm-agents.overlays.default];

  nichts.aspects.llm-agents.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
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
