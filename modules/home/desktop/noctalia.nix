{ pkgs, ... }:
{
  home.packages = [ pkgs.noctalia-shell ];

  xdg.configFile = {
    "noctalia/colors.json".source = ../../../config/noctalia/colors.json;
    "noctalia/plugins.json".source = ../../../config/noctalia/plugins.json;
    "noctalia/settings.json".source = ../../../config/noctalia/settings.json;
  };
}
