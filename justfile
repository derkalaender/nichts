# Activate the configuration, add it to boot loader and mark it as default
switch:
    nh os switch .

# Activate the configuration without adding it to boot loader (after reboot, the changes are lost)
test:
    nh os test .

# Rollback to the previous configuration, add it to boot loader and mark it as default
[confirm]
rollback:
    sudo nixos-rebuild boot --rollback

# Validates the flake
check:
    nix flake check

# List flake inputs
info:
    nix flake info

# Starts repl, allows inspection
repl:
    nix repl --expr 'builtins.getFlake "{{justfile_directory()}}"'

# Add missing inputs to lockfile, but don't update existing ones
lock:
    nix flake lock

# Update flake inputs. If no inputs specified, updates all inputs
update *inputs:
    nix flake update {{inputs}}

# Generate a new key at $HOME/.config/sops/age/keys.txt but ask to proceed if already exists
sops-genkey:
    mkdir -p ~/.config/sops/age
    nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt

# Edit a secret using sops
sops-edit file:
    nix run nixpkgs#sops -- {{file}}

# Rekey all secrets
sops-rekey:
    find secrets -name '*.yaml' -exec nix run nixpkgs#sops -- updatekeys {} \;
