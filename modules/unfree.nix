{
  flake.modules.nixos.core = {
    nixpkgs.config.allowUnfree = true;
  };
}
