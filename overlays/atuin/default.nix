# BUG: Up-key doesn't work with latest version in Ghostty; FIX: use older version
# https://github.com/atuinsh/atuin/issues/2718
# BUG: Up-key doesn't work with fish 4.0; FIX: use patch from PR
# https://github.com/atuinsh/atuin/pull/2616 and https://github.com/pbek/nixcfg/commit/0063ba615b9f9b9126755efa720bd4acc0fb1a4f#diff-a5dc9e5faded2d24dd4bbc9dfa465720e71e42c09aaef9f6626c96f211a6d105R298
{...}: final: prev: let
  inherit (prev) fetchFromGitHub rustPlatform;
in {
  atuin = prev.atuin.overrideAttrs (old: rec {
    # https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/at/atuin/package.nix
    version = "18.4.0";
    src = fetchFromGitHub {
      owner = "atuinsh";
      repo = "atuin";
      tag = "v${version}";
      hash = "sha256-P/q4XYhpXo9kwiltA0F+rQNSlqI+s8TSi5v5lFJWJ/4=";
    };

    # https://discourse.nixos.org/t/nixpkgs-overlay-for-mpd-discord-rpc-is-no-longer-working/59982/2
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-0KswWFy44ViPHlMCmwgVlDe7diDjLmVUk2517BEMTtk=";
    };

    patches = old.patches ++ [./2616.patch];
  });
}
