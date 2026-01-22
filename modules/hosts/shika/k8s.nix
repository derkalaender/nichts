{
  flake.modules.nixos.host_shika = {pkgs, ...}: {
    virtualisation.podman.enable = true;

    environment.systemPackages = with pkgs; [
      kubectl
      k9s
      helm
      kustomize
      kind
      minikube
      kn
    ];
  };
}
