{ pkgs, ... }:
{
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  gtk = {
    enable = true;
    theme = {
      name = "rose-pine";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  xdg.configFile = {
    "kdeglobals".text = ''
      [General]
      ColorScheme=rose-pine-iris

      [Colors:View]
      BackgroundAlternate=25,23,36
      BackgroundNormal=25,23,36
      ForegroundNormal=224,222,244

      [Colors:Window]
      BackgroundNormal=31,29,46
      ForegroundNormal=224,222,244
    '';
    "qt6ct/qt6ct.conf".text = ''
      [Appearance]
      icon_theme=Papirus-Dark
      style=kvantum
    '';
    "qt5ct/qt5ct.conf".text = ''
      [Appearance]
      icon_theme=Papirus-Dark
      style=kvantum
    '';
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=rose-pine-iris
    '';
    "Kvantum/rose-pine-iris/rose-pine-iris.svg".source =
      "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-iris/rose-pine-iris.svg";
    "Kvantum/rose-pine-iris/rose-pine-iris.kvconfig".text = ''
      [General]
      name=Rose Pine Iris
      author=rose-pine
      translucent_windows=true
      blurring=true
      transparent_dolphin_view=true
      respect_DE=false
    '';
  };
}
