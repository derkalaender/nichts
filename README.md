# nichts - My personal NixOS configurations
<sup>nichts (colloquially: *nix*) meaning "nothing" in German</sup>

NixOS configurations for my desktops, laptops and servers, built with
[flake-parts](https://flake.parts) and the dendritic pattern: every piece of the
configuration is a flake-parts module, and `flake.nix` only declares inputs,
nix settings and where to find them.

## Layout

```
flake.nix         inputs, nixConfig, and one imports line that collects every
                  nix/**/*.mod.nix file as a flake-parts module
nix/lib/          plain library functions, exposed as nichts.lib.<name>
nix/options/      flake-level options and the wiring between them: nichts.lib,
                  nichts.overlays, nichts.modules.{nixos,home},
                  nichts.entities.{hosts,users}, flake.nixosConfigurations,
                  deploy-rs, disko, images, treefmt
nix/modules/      units of system and home configuration
nix/hosts/        host entities
nix/users/        user entities
nix/packages/     custom packages, with their perSystem declarations next to them
nix/secrets/      secrets that belong to no single host or user
```

Files without the `.mod.nix` suffix are *not* collected: they are plain Nix and
are only used when something imports them explicitly (`nix/lib` helpers,
`nix/packages` definitions, a host's `disko.nix` and `deploy.nix`, host-local
NixOS modules like `sops.nix`, secrets, `facter.json`).

## Units

A unit is one file in `nix/modules` that declares the NixOS and/or Home Manager
module it contributes:

```nix
{nichts, ...}: {
  nichts.modules.nixos.game-thing = {...};
  nichts.modules.home.game-thing = {...};
}
```

Units are addressed by name, so a host (or a user) can import exactly what it
wants: `imports = with nichts.modules.nixos; [desktop gaming];`. The module
system deduplicates them by `key`, so a host and one of its users can both ask
for `desktop` and it is only evaluated once. `nichts.modules.nixos.default` and
`nichts.modules.home.default` are the units every host and user gets, composed in
`nix/modules/default.mod.nix`.

## Hosts and users

```nix
# nix/hosts/shika/shika.mod.nix
{config, nichts, ...}: {
  imports = [./disko.nix];

  nichts.entities.hosts.shika = {
    users = ["marvin"];
    module = {
      nixos = {pkgs, lib, ...}: {imports = with nichts.modules.nixos; [desktop ...];};
      home = {};   # Home Manager defaults for this host's users, if any
    };
  };
}
```

A host becomes `flake.nixosConfigurations.<name>`; `hostname` defaults to the
host's attribute name and `system` to `x86_64-linux`. Its Home Manager users get
`nichts.modules.home.default` plus the host's `module.home` plus the user's own
`module.home`.

```nix
# nix/users/marvin/marvin.mod.nix
{nichts, ...}: {
  nichts.entities.users.marvin.module = {
    nixos = {config, ...}: {users.users.marvin = {...};};
    home = {pkgs, ...}: {imports = with nichts.modules.home; [browser terminal ...];};
  };
}
```

Users do nothing on their own: a host has to list them, which pulls in both sides
and sets up Home Manager for them.

## Secrets

A secret belongs to exactly one user or host and lives with it:

- `nix/hosts/<host>/secrets/`, `nix/users/<user>/secrets/`, and `nix/secrets/`
  only for secrets that belong to no single entity
- the sops configuration for it (`sops.age.keyFile`, `sops.defaultSopsFile`) sits
  in that entity's own module
- `.sops.yaml` maps each path to its recipients; after moving a secret file, run
  `just sops-rekey` so the file's recipients follow

Shared units never touch sops. When a shared unit needs a secret it declares an
option, and the host or user wires `config.sops.secrets.<name>.path` into it
(`nichts.atuin.key` and `nichts.atuin.session` are examples).
