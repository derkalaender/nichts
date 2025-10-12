{
  self,
  inputs,
  config,
  ...
}: {
  nichts.hosts.shika = {
    system = "x86_64-linux";
  };

  flake.modules.nixos.host_shika = {
    imports =
      [
        "${self}/OLD/systems/x86_64-linux/shika/default.nix"
        config.flake.modules.nixos.gaming
      ]
      ++ (with inputs; [
        nixos-hardware.nixosModules.common-pc
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-cpu-intel
        nixos-hardware.nixosModules.common-gpu-intel
        nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
      ]);
  };
}
