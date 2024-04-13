# Activate the configuration, add it to boot loader and mark it as default
switch:
    sudo nixos-rebuild switch

# Activate the configuration without adding it to boot loader (after reboot, the changes are lost)
test:
    sudo nixos-rebuild test

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

# Update flake inputs. If no inputs specified, updates all inputs
update *inputs:
    nix flake {{ if inputs == "" { "update" } else { "lock --update-input " + inputs } }}
