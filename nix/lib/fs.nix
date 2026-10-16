{self}: rec {
  # Paths into the flake source, as strings rather than paths: sops-nix reads
  # these at build time, and a string keeps the reference inside the source tree
  # instead of copying the file into the store on its own.
  get-file = p: "${self}/${p}";

  # Secrets that belong to no single entity.
  secret = p: get-file "secrets/${p}";

  # Per-entity secrets, so a host or user owns its own encrypted files.
  host = host: file: get-file "nix/hosts/${host}/secrets/${file}";
  user = user: file: get-file "nix/users/${user}/secrets/${file}";
}
