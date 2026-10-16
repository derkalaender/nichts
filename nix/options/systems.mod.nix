{ lib, ... }: {
  # Which systems flake-parts generates per-system outputs for (packages,
  # checks, formatter). Hosts choose the system they are built for themselves.
  systems = lib.mkDefault lib.systems.flakeExposed;
}
