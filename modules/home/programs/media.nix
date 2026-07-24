{ pkgs, ... }: {
  programs = {
    btop.enable = true;
    mpv = {
      enable = true;
      scripts = [ pkgs.mpvScripts.uosc ];
      config = {
        osc = false;
        osd-bar = false;
        border = false;
      };
    };
  };

  xdg.configFile = {
    "btop/btop.conf".source = ../../../config/btop/btop.conf;
    "rmpc/config.ron".source = ../../../config/rmpc/config.ron;
    "rmpc/themes/cosmic_red.ron".source = ../../../config/rmpc/themes/cosmic_red.ron;
    "rmpc/themes/rose_pine.ron".source = ../../../config/rmpc/themes/rose_pine.ron;
    "rmpc/themes/default.ron".source = ../../../config/rmpc/themes/default.ron;
    "rmpc/themes/mei.ron".source = ../../../config/rmpc/themes/mei.ron;
  };
}
