# Testing

nix --experimental-features "nix-command flakes"

nix --experimental-features "nix-command flakes" flake --accept-flake-config check .

nix --experimental-features "nix-command flakes" repl --accept-flake-config . 


# Format Disks

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --root-mountpoint /mnt/nixos --dry-run -m destroy,format,mount modules/hosts/shika/_disko-config.nix

nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --root-mountpoint /mnt/nixos -m destroy,format,mount modules/hosts/shika/_disko-config.nix


# Generate secrets
nix-shell -p sops age

mkdir -p secrets
age-keygen -o secrets/host.txt
age-keygen -o secrets/user.txt

# Update secrets
## Edit recipients in .sops.yaml
## Then rekey:
export SOPS_AGE_KEY=...
find secrets -type f -exec sops updatekeys --yes {} \;


# Install

sudo nixos-install --root /mnt/nixos --flake .#shika
sudo mkdir -p /mnt/nixos/root/.config/sops/age
sudo cp keys/host.txt /mnt/nixos/root/.config/sops/age/keys.txt
sudo nixos-enter --root /mnt/nixos

Maybe set @ as default btrfs subvolume?
