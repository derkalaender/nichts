{pkgs, ...}:
pkgs.buildGoModule rec {
  pname = "wsl2-ssh-agent";
  version = "0.9.6";

  src = pkgs.fetchFromGitHub {
    owner = "mame";
    repo = "wsl2-ssh-agent";
    rev = "v${version}";
    hash = "sha256-oFlp6EIh32tuqBuLlSjURpl85bzw1HymJplXoGJAM8k=";
  };

  vendorHash = "sha256-YnqpP+JkbdkCtmuhqHnKqRfKogl+tGdCG11uIbyHtlI=";

  # Tests are broken
  doCheck = false;

  meta = with pkgs.lib; {
    description = "WSL2 forwarding ssh-agent from Windows";
    homepage = "https://github.com/mame/wsl2-ssh-agent";
    license = licenses.mit;
  };
}
