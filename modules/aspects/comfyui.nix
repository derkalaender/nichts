{inputs, ...}: {
  flake-file.inputs = {
    comfyui-nix.url = "github:utensils/comfyui-nix";
  };

  nichts.overlays = [inputs.comfyui-nix.overlays.default];

  nichts.aspects.comfyui.nixos = {
    # Upstream sets nixpkgs.overlays which is incompatible with the read-only way we're doing.
    # This ugly hack imports the module directly.
    imports = ["${inputs.comfyui-nix}/nix/modules/comfyui.nix"];

    services.comfyui = {
      enable = true;
      gpuSupport = "rocm";
      enableManager = true;
      extraArgs = [
        "--use-pytorch-cross-attention" # TODO: wait for upstream to update to ROCm 7.2 and update comfyui, as this isnt needed there anymore
      ];
    };
  };
}
