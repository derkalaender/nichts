{pkgs, ...}: {
  environment.systemPackages = with pkgs; [nichts.wsl2-ssh-agent];

  systemd.user.services.wsl2-ssh-agent = {
    description = "WSL2 forwarding ssh-agent from Windows";
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.nichts.wsl2-ssh-agent}/bin/wsl2-ssh-agent --foreground --verbose";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
