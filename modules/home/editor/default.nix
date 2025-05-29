{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.nichts; let
  cfg = config.nichts.editor;
in {
  options.nichts.editor = {
    helix = mkEnableOpt "Helix editor";
    jetbrains = mkEnableOpt "JetBrains IDEs";
    vscode = mkEnableOpt "Visual Studio Code";
  };

  config = mkMerge [
    (mkIf cfg.helix.enable {
      programs.helix =
        enabled
        // {
          package = pkgs.unstable.helix;
          defaultEditor = true;
        };
    })

    (mkIf cfg.jetbrains.enable {
      home.packages = with pkgs.unstable; [
        android-studio
        jetbrains.idea-ultimate
        jetbrains.clion
        jetbrains.pycharm-professional
      ];
    })

    (mkIf cfg.vscode.enable {
      home.packages = with pkgs; [
        vscode.fhs
      ];
    })
  ];
}
