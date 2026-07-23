{ pkgs, lib, ... }:
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
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
  };

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
    "pcmanfm-qt/default/settings.conf".text = ''
      [System]
      IconThemeName=Papirus-Dark
      Terminal=wezterm

      [Desktop]
      BgColor=#1f1d2e
      FgColor=#e0def4
      ShadowColor=#000000
    '';
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=rose-pine-iris
    '';
    "Kvantum/rose-pine-iris/rose-pine-iris.svg".source =
      "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-iris/rose-pine-iris.svg";
    "Kvantum/rose-pine-iris/rose-pine-iris.kvconfig".text =
      builtins.replaceStrings
        [
          "translucent_windows=false"
          "blurring=false"
          "transparent_dolphin_view=false"
          "31,29,46"
          "respect_DE=true"
        ]
        [
          "translucent_windows=true"
          "blurring=true"
          "transparent_dolphin_view=true"
          "25,23,36"
          "respect_DE=false"
        ]
        (
          builtins.readFile "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/rose-pine-iris/rose-pine-iris.kvconfig"
        );
  };
}
