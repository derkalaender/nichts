{...}: {
  nichts.aspects.llama.nixos = {pkgs, ...}: let
    llama-cpp = pkgs.llama-cpp-vulkan;
  in {
    environment.systemPackages = [
      llama-cpp
      pkgs.llmfit
    ];

    services.llama-swap = {
      enable = true;
    };
  };
}
