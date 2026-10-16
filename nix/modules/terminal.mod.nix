{
  nichts.modules.terminal.home = {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = true;
      extraConfig = ''
        local config = wezterm.config_builder()

        -- Launch fish by default
        config.default_prog = { 'fish', '-l' }

        config.enable_scroll_bar = true

        config.color_scheme = 'catppuccin-mocha'
        config.font = wezterm.font 'Lilex Nerd Font Mono'

        return config
      '';
    };
  };
}
