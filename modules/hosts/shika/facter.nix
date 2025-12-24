{
  flake.modules.nixos.host_shika = {inputs, ...}: {
    imports = [inputs.nixos-facter-modules.nixosModules.facter];
    facter.reportPath = ./facter.json;
  };
}
