#!/usr/bin/env bash

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sops-nix expects to find the age key
install -d -m755 "$temp/root/.config/sops/age"

# Copy the age key to the temporary directory
cp keys.txt "$temp/root/.config/sops/age/keys.txt"

# Set the correct permissions
chmod 600 "$temp/root/.config/sops/age/keys.txt"

# Install NixOS to the host system with our secrets
nix run nixpkgs#nixos-anywhere -- --extra-files "$temp" --flake '.#kawauso' --target-host root@192.168.178.54
