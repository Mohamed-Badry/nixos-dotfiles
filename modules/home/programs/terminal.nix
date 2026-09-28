{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs = {
    helix.enable = true;
    zellij.enable = true;
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "org.wezfurlong.wezterm.desktop" ];
    };
  };

  home.sessionVariables = {
    TERMINAL = "wezterm";
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      config.bidi_enabled = true
      config.bidi_direction = 'AutoLeftToRight'
      config.font = wezterm.font_with_fallback { 'JetBrains Mono', 'JetBrainsMono Nerd Font', 'Kawkab Mono' }
      config.font_size = 12.0
      config.window_background_opacity = 0.93
      config.window_decorations = 'NONE'
      config.enable_tab_bar = false
      config.initial_cols = 120
      config.initial_rows = 35
      config.window_close_confirmation = 'NeverPrompt'
      config.color_scheme = 'Noctalia'
      config.default_prog = { '${pkgs.bash}/bin/bash' }
      return config
    '';
  };

  xdg.configFile = {
    "helix/config.toml".source = ../../../config/terminal/helix/config.toml;
    "helix/languages.toml".source = ../../../config/terminal/helix/languages.toml;
    "helix/themes/cosmic_red.toml".source = ../../../config/terminal/helix/themes/cosmic_red.toml;

    "zellij/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/terminal/zellij/config.kdl";
    "zellij/themes".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/terminal/zellij/themes";
    "zellij/layouts".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/terminal/zellij/layouts";
    "zellij/plugins/zjstatus.wasm".source = pkgs.zellijPlugins.zjstatus;
    "zellij/plugins/zellij-autolock.wasm".source = pkgs.fetchurl {
      url = "https://github.com/fresh2dev/zellij-autolock/releases/download/0.2.2/zellij-autolock.wasm";
      sha256 = "194fgd421w2j77jbpnq994y2ma03qzdlz932cxfhfznrpw3mdjb9";
    };
  };
}
