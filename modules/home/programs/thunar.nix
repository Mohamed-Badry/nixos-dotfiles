_: {
  gtk.gtk3.extraCss = ''
    /* Thunar Shapes & Layout Styling */
    window.thunar,
    .thunar {
      border: none;
      box-shadow: none;
    }

    .thunar .sidebar,
    .thunar .sidebar .view,
    .thunar .sidebar treeview.view {
      border-right: none;
      padding: 8px 6px;
    }

    .thunar .sidebar treeview.view:hover {
      border-radius: 8px;
    }

    .thunar .sidebar treeview.view:selected {
      font-weight: 500;
      border-radius: 8px;
    }

    .thunar .standard-view,
    .thunar .standard-view .view,
    .thunar .standard-view exo-icon-view,
    .thunar .standard-view treeview.view {
      border: none;
      box-shadow: none;
    }

    .thunar .standard-view exo-icon-view:selected,
    .thunar .standard-view treeview.view:selected {
      border-radius: 8px;
    }

    .thunar .standard-view exo-icon-view:hover,
    .thunar .standard-view treeview.view:hover {
      border-radius: 8px;
    }

    /* Thin divider between sidebar and main view */
    .thunar paned > separator {
      min-width: 1px;
      min-height: 1px;
      border: none;
    }

    /* Location / Breadcrumb Toolbar */
    window.thunar toolbar#location-toolbar {
      border: none;
      box-shadow: none;
      padding: 6px 12px;
    }

    window.thunar toolbar#location-toolbar > toolitem > widget > widget.linked.path-bar > button.path-bar-button {
      border-style: solid;
      border-width: 1px;
      border-radius: 8px;
      margin: 2px 3px;
      padding: 3px 8px;
      box-shadow: none;
      transition: all 120ms ease-in-out;
    }

    window.thunar toolbar#location-toolbar > toolitem > widget > widget.linked.path-bar > button.toggle.path-bar-button:checked {
      font-weight: bold;
      border-radius: 8px;
    }

    /* Toolbar buttons & inputs */
    .thunar toolbar button {
      border-radius: 8px;
    }

    .thunar entry {
      border-radius: 8px;
    }

    /* Tabs */
    .thunar notebook tab {
      border-radius: 8px 8px 0 0;
      padding: 4px 8px;
    }

    /* Minimalist scrollbar */
    .thunar scrollbar {
      border: none;
    }

    .thunar scrollbar slider {
      border-radius: 6px;
      min-width: 5px;
      min-height: 5px;
      border: none;
    }

    /* Context Menus & Popups */
    .thunar menu,
    .thunar .menu {
      border-radius: 10px;
      padding: 4px;
    }

    .thunar menu menuitem,
    .thunar .menu menuitem {
      border-radius: 6px;
      padding: 4px 8px;
    }
  '';

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

  xdg.configFile = {
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
