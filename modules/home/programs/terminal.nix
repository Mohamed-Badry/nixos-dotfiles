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
  };

  xdg.configFile = {
    "wezterm/wezterm.lua".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/terminal/wezterm/wezterm.lua";

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
