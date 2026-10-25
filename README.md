# nichts - My personal NixOS configurations

NixOS configurations for my desktops, laptops and servers, built with
[flake-parts](https://flake.parts) and the dendritic pattern.

## Layout

```
nichts
│─ flake.nix                            # entrypoint
│─ justfile                             # command runner specification
│─ .sops.yaml                           # SOPS secret identities
└─ nix
  ├─ lib                                # custom library functions
  ├─ flake                              # flake-level configuration
  ├─ modules                            # shared modules
  ├─ packages                           # custom packages
  ├─ hosts                              # host-specific nixos configuration
  │ └─ <host>
  │   └─ secrets                        # host-specific secrets
  ├─ users                              # user-specific home-manager configuration
  │ └─ <user>
  │   └─ secrets                        # user-specific secrets
  └─ secrets                            # common secrets
```

The flake entrypoint collects every `nix/**/*.mod.nix` file as a flake-parts module.
This way, files without a `.mod.nix` suffix are *not* collected and can be imported explicitly.

## Units

A unit is one file in `nix/modules` that declares the NixOS and/or Home Manager
module it contributes. Both sides of a unit sit together, so a unit reads as one
thing:

```nix
{nichts, ...}: {
  nichts.modules.game-thing = {
    nixos = {...};   # the NixOS side
    home = {...};    # the Home Manager side
  };
}
```

Importing stays short: `nichts.lib.units.nixos` (and `.home`) is the same
registry with one class picked out, so a host or user lists exactly what it wants:

```nix
imports = with nichts.lib.units.nixos; [desktop gaming];
imports = with nichts.lib.units.home; [browser terminal];
```

The module system deduplicates units by `key`, so a host and one of its users may
both ask for `desktop` and it is only evaluated once; `_class` makes importing a
Home Manager unit into NixOS an error instead of a silent no-op.
`nichts.modules.default.nixos` / `.home` are the units every host and user gets,
composed in `nix/modules/default.mod.nix`.

A unit is also one *concept*, so importing its NixOS side gives its Home Manager
side to every user of that host — the two only make sense together.
Importing `home` directly is for user-only units such as `browser` or `spotify`.

## Hosts and users

```nix
# nix/hosts/shika/shika.mod.nix
{config, nichts, ...}: {
  imports = [./disko.nix];

  nichts.entities.hosts.shika = {
    users = ["marvin"];
    module = {pkgs, lib, ...}: {
      imports = with nichts.lib.units.nixos; [desktop gaming ...];
    };
  };
}
```

A host becomes `flake.nixosConfigurations.<name>`; `hostname` defaults to the
host's attribute name and `system` to `x86_64-linux`. A host's module is NixOS
only: every user it lists gets the default user-side units, the user-side units
its NixOS imports couple in, and its own module. A host that wants a
Home-Manager-only unit for *everyone* on it adds it to
`home-manager.sharedModules` in that same NixOS module.

```nix
# nix/users/marvin/marvin.mod.nix
{nichts, ...}: {
  # What makes marvin an account is data: the flake turns it into
  # users.users.marvin, so every host wires accounts the same way.
  nichts.entities.users.marvin.description = "Marvin UwU";
  nichts.entities.users.marvin.extraGroups = ["wheel" "networkmanager" ...];

  # The rest is a Home Manager module.
  nichts.entities.users.marvin.module = {pkgs, ...}: {
    imports = with nichts.lib.units.home; [browser terminal ...];
  };
}
```

Users do nothing on their own: a host has to list them, which generates the
account and sets up Home Manager for them.

## Secrets

Secrets are age-encrypted and managed through SOPS. Each secret belongs to exactly one user or host.

`.sops.yaml` maps each path to its recipients; after moving a secret file, run `just sops-rekey` so the file's recipients follow

Shared units never touch sops: when a unit needs a secret it declares an option
and the host or user wires `config.sops.secrets.<name>.path` into it
(`nichts.atuin.key` is an example).

The one thing the flake cannot generate is an account's password. The user entity
says *what* the account is; the host that provides the user owns the secret and
supplies it as `users.users.<name>.hashedPasswordFile`, next to declaring
`sops.secrets."user_passwords/<name>"` in its `sops.nix`.
