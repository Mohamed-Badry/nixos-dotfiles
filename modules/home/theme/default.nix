{
  config,
  pkgs,
  lib,
  ...
}:
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
    gtk3.extraConfig = {
      gtk-recent-files-enabled = false;
      gtk-recent-files-max-age = 0;
    };
    gtk3.extraCss = ''
      @import url("noctalia.css");

      /* Thunar Dynamic Noctalia Caelestia Styling */
      window.thunar,
      .thunar {
          background-color: alpha(@window_bg_color, 0.88);
          border: none;
          box-shadow: none;
      }

      .thunar .sidebar,
      .thunar .sidebar .view,
      .thunar .sidebar treeview.view {
          background-color: alpha(@sidebar_bg_color, 0.55);
          border-right: none;
          padding: 8px 6px;
      }

      .thunar .sidebar treeview.view:hover {
          background-color: alpha(@accent_bg_color, 0.10);
          border-radius: 8px;
      }

      .thunar .sidebar treeview.view:selected {
          background-color: alpha(@accent_bg_color, 0.22);
          color: @sidebar_fg_color;
          font-weight: 500;
          border-radius: 8px;
      }

      .thunar .standard-view,
      .thunar .standard-view .view,
      .thunar .standard-view exo-icon-view,
      .thunar .standard-view treeview.view {
          background-color: transparent;
          border: none;
          box-shadow: none;
      }

      .thunar .standard-view exo-icon-view:selected,
      .thunar .standard-view treeview.view:selected {
          background-color: alpha(@accent_bg_color, 0.22);
          color: @window_fg_color;
          border-radius: 8px;
      }

      .thunar .standard-view exo-icon-view:hover,
      .thunar .standard-view treeview.view:hover {
          background-color: alpha(@accent_bg_color, 0.08);
          border-radius: 8px;
      }

      /* Thin elegant divider between sidebar and main view */
      .thunar paned > separator {
          background-color: alpha(@window_fg_color, 0.12);
          min-width: 1px;
          min-height: 1px;
          border: none;
      }

      /* Location / Breadcrumb Toolbar */
      window.thunar toolbar#location-toolbar {
          border: none;
          background: transparent;
          box-shadow: none;
          padding: 6px 12px;
      }

      window.thunar toolbar#location-toolbar > toolitem > widget > widget.linked.path-bar > button.path-bar-button {
          background: alpha(@card_bg_color, 0.65);
          border: 1px solid alpha(@window_fg_color, 0.15);
          border-radius: 8px;
          margin: 2px 3px;
          padding: 3px 8px;
          box-shadow: none;
          color: @window_fg_color;
          transition: all 120ms ease-in-out;
      }

      window.thunar toolbar#location-toolbar > toolitem > widget > widget.linked.path-bar > button.path-bar-button:hover {
          background: alpha(@card_bg_color, 0.85);
          border-color: alpha(@accent_bg_color, 0.4);
      }

      window.thunar toolbar#location-toolbar > toolitem > widget > widget.linked.path-bar > button.toggle.path-bar-button:checked {
          background: @accent_bg_color;
          color: @accent_fg_color;
          font-weight: bold;
          border-radius: 8px;
          border: 1px solid @accent_bg_color;
      }

      /* Minimalist scrollbar */
      .thunar scrollbar {
          background: transparent;
          border: none;
      }

      .thunar scrollbar slider {
          background-color: alpha(@window_fg_color, 0.25);
          border-radius: 6px;
          min-width: 5px;
          min-height: 5px;
          border: none;
      }

      .thunar scrollbar slider:hover {
          background-color: alpha(@accent_bg_color, 0.5);
      }

      /* Context Menus & Popups */
      .thunar menu,
      .thunar .menu {
          background-color: alpha(@popover_bg_color, 0.95);
          border: 1px solid alpha(@window_fg_color, 0.20);
          border-radius: 10px;
          padding: 4px;
      }

      .thunar menu menuitem,
      .thunar .menu menuitem {
          color: @popover_fg_color;
          border-radius: 6px;
          padding: 4px 8px;
      }

      .thunar menu menuitem:hover,
      .thunar .menu menuitem:hover {
          background-color: alpha(@accent_bg_color, 0.20);
          color: @popover_fg_color;
      }
    '';
    gtk4.extraConfig = {
      gtk-recent-files-enabled = false;
    };
  };

  xfconf.settings = {
    thunar = {
      "last-menubar-visible" = false;
      "last-statusbar-visible" = true;
      "last-location-bar" = "ThunarLocationButtons";
      "misc-single-click" = false;
      "misc-show-delete-action" = true;
      "shortcuts-icon-size" = "THUNAR_ICON_SIZE_16";
      "misc-confirm-close-multiple-tabs" = false;
      "misc-middle-click-in-tab" = true;
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
    "pcmanfm-qt/default/settings.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/pcmanfm-qt/settings.conf";
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
    "Thunar/uca.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <actions>
        <action>
          <icon>org.wezfurlong.wezterm</icon>
          <name>Open Terminal Here</name>
          <submenu></submenu>
          <unique-id>terminal-open-here</unique-id>
          <command>sh -c 'if [ -d "$1" ]; then wezterm start --cwd "$1"; else wezterm start --cwd "$(dirname "$1")"; fi' _ %f</command>
          <description>Open WezTerm in current folder</description>
          <range></range>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
          <audio-files/>
          <image-files/>
          <other-files/>
          <text-files/>
          <video-files/>
        </action>
      </actions>
    '';
    "xfce4/helpers.rc".text = ''
      [Default]
      TerminalEmulator=wezterm.desktop
    '';
  };

  xdg.dataFile = {
    "xfce4/helpers/wezterm.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Icon=org.wezfurlong.wezterm
      Type=X-XFCE-Helper
      Name=WezTerm
      StartupNotify=true
      X-XFCE-Binaries=wezterm;
      X-XFCE-Category=TerminalEmulator
      X-XFCE-Commands=wezterm
      X-XFCE-CommandsWithParameter=wezterm start --cwd %s
    '';
  };
}
