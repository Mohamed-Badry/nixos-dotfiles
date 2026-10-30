{
  config,
  pkgs,
  ...
}:
{
  programs = {
    btop.enable = true;
    mpv = {
      enable = true;
      scripts = [ pkgs.mpvScripts.uosc ];
      config = {
        osc = false;
        osd-bar = false;
        border = false;
        gpu-api = "opengl";
        hwdec = "auto-safe";
      };
    };
  };

  xdg.configFile = {
    "btop/btop.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/btop/btop.conf";
  };
}
