# Activate the configuration, add it to boot loader and mark it as default
switch:
    nh os switch . -- --option accept-flake-config true

# Add the configuration to the bootloader with activating it
boot:
    nh os boot . -- --option accept-flake-config true

# Activate the configuration without adding it to boot loader (after reboot, the changes are lost)
test:
    nh os test .  -- --option accept-flake-config true

# Rollback to the previous configuration, add it to boot loader and mark it as default
[confirm]
rollback:
    sudo nixos-rebuild boot --rollback

# Validates the flake, including the treefmt formatting check
check:
    nix flake check --all-systems --option accept-flake-config true

# List flake inputs
info:
    nix flake metadata

# Starts repl, allows inspection
repl:
    nix repl --expr 'builtins.getFlake "{{justfile_directory()}}"'

# Add missing inputs to lockfile, but don't update existing ones
lock:
    nix flake lock --option accept-flake-config true

# Update flake inputs. If no inputs specified, updates all inputs
update *inputs:
    nix flake update {{inputs}} --option accept-flake-config true

# Format the tree with treefmt (nixfmt)
fmt:
    nix fmt --option accept-flake-config true

# Generate an installer iso
iso:
    nix build .#generators.install-iso --option accept-flake-config true

# Generate a new key at $HOME/.config/sops/age/keys.txt but ask to proceed if already exists
sops-genkey:
    mkdir -p ~/.config/sops/age
    nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt

# Edit a secret using sops
sops-edit file:
    nix run nixpkgs#sops -- {{file}}

# Rekey all secrets
sops-rekey:
    find nix -name '*.yaml' -exec nix run nixpkgs#sops -- updatekeys {} \;

# Deploy to remote machine
deploy host:
    nix run github:serokell/deploy-rs -- .#{{host}} -- --option accept-flake-config true

# Deploy to remote machine (dry activate)
deploy-dry host:
    nix run github:serokell/deploy-rs -- .#{{host}} --dry-activate -- --option accept-flake-config true
