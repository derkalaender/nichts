{
  nichts.aspects.editor.homeManager = {pkgs, ...}: let
    # This patched openssh removes permission checks on ssh config files.
    # This is needed for FHS environments.
    # See https://github.com/nix-community/home-manager/issues/322#issuecomment-1178614454 and https://github.com/nix-community/home-manager/issues/322#issuecomment-2265431023
    patched-openssh = pkgs.openssh.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./openssh.patch];
    });
  in {
    programs.helix = {
      enable = true;
      defaultEditor = true;
    };

    home.packages = with pkgs;
      [
        android-studio

        (vscode.fhsWithPackages (_: [patched-openssh]))
        zed-editor
      ]
      ++ (with pkgs.jetbrains; [
        idea
        clion
        pycharm
      ]);
  };
}
