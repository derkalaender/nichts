{...}: {
  nichts.aspects.llama.nixos = {
    pkgs,
    lib,
    ...
  }: let
    llama-cpp = pkgs.llama-cpp-vulkan;
    llama-server = lib.getExe' llama-cpp "llama-server";

    modelsDir = "/models/llamacpp";
    mkModel = {
      name,
      file,
      ctxSize,
      ttl,
      args ? {},
    }: {
      inherit name ttl;
      capabilities = {
        "in" = ["text"];
        out = ["text"];
        tools = true;
        context = ctxSize;
      };
      cmd = "${llama-server} ${lib.cli.toGNUCommandLineShell {} (args
        // {
          model = "${modelsDir}/${file}";
          port = "\${PORT}";
          ctx-size = ctxSize;
          flash-attn = "on";
          jinja = true;
          offline = true;
        })}";
    };
  in {
    environment.systemPackages = [
      llama-cpp
      pkgs.llmfit
    ];

    services.llama-swap = {
      enable = true;
      settings = {
        healthCheckTimeout = 60;
        logLevel = "info";

        models = {
          "qwen3.6-35b-a3b" = mkModel {
            name = "Qwen3.6 35B A3B (UD Q4_K_M)";
            file = "Qwen3.6-35B-A3B-UD-Q4_K_M.gguf";
            ctxSize = 256 * 1024;
            ttl = 5 * 60;
            args = {
              # Performance
              n-gpu-layers = "all";
              cpu-moe = true;
              spec-type = "draft-mtp";
              spec-draft-n-max = 3;
              batch-size = 4 * 1024;
              ubatch-size = 4 * 1024;
              # Cache quality
              cache-type-k = "q8_0";
              cache-type-v = "q8_0";
              cache-type-k-draft = "q8_0";
              cache-type-v-draft = "q8_0";
              # Behavior
              temp = 1.0;
              top-p = 0.95;
              top-k = 20;
              min-p = 0.0;
              presence-penalty = 0.0;
              repeat-penalty = 1.0;
            };
          };
          "sweep-next-edit-1.5b" = mkModel {
            name = "Sweep Next Edit 1.5B (Q8_0)";
            file = "sweep-next-edit-1.5b.q8_0.v2.gguf";
            ctxSize = 32 * 1024;
            ttl = 10 * 60;
            args = {
              n-gpu-layers = "all";
            };
          };
        };
      };
    };
  };
}
