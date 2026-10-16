{inputs, ...}: {
  nichts.overlays = [
    # Manual import so that it's in the global package set
    inputs.comfyui-nix.overlays.default
  ];

  nichts.modules.nixos.comfyui = {
    pkgs,
    lib,
    ...
  }: let
    # See https://github.com/Comfy-Org/ComfyUI/blob/master/folder_paths.py
    modelKeys = [
      "checkpoints"
      "configs"
      "loras"
      "vae"
      "text_encoders"
      "diffusion_models"
      "clip_vision"
      "style_models"
      "embeddings"
      "diffusers"
      "vae_approx"
      "controlnet"
      "gligen"
      "upscale_models"
      "latent_upscale_models"
      "hypernetworks"
      "photomaker"
      "classifiers"
      "model_patches"
      "audio_encoders"
      "background_removal"
      "frame_interpolation"
      "geometry_estimation"
      "optical_flow"
      "detection"
    ];

    extraModelPaths =
      {
        comfyui = {base_path = "/models/comfyui/";} // lib.attrsets.genAttrs modelKeys (key: "${key}/");
      }
      |> lib.generators.toYAML {}
      |> pkgs.writeText "extra_model_paths.yaml";
  in {
    # Use community module instead of nixpkgs, as the nixpkgs one hardcodes NVIDIA CUDA and does not support ROCm.
    imports = [inputs.comfyui-nix.nixosModules.default];

    services.comfyui = {
      enable = false; # Currently broken; see https://github.com/NixOS/nixpkgs/issues/570271 and https://github.com/NixOS/nixpkgs/commit/20f328cd6386a6a1efb410c81fa764eb6d3d73d0
      package = pkgs.comfy-ui-rocm; # Force this version from utensils/comfyui-nix
      gpuSupport = "rocm";
      enableManager = true;
      extraArgs = [
        "--use-pytorch-cross-attention" # TODO: wait for upstream to update to ROCm 7.2 and update comfyui, as this isnt needed there anymore
        "--extra-model-paths-config"
        "${extraModelPaths}"
      ];
    };
  };
}
