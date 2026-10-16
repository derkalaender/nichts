{nichts, ...}: {
  nichts.modules.nixos.kubernetes-tools = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      kubectl
      k9s
      kubernetes-helm
      kustomize
      kind
      minikube
      kn
      fluxcd
      telepresence2
      sshfs # needed by telepresence2
      cloudflared
    ];
  };
}
