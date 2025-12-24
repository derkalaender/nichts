{
  flake.modules.nixos.host_shika = {
    inherit (import ./_disko-config.nix) disko;
  };
}
