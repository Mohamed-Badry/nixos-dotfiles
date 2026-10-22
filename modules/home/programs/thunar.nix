_:
{
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
