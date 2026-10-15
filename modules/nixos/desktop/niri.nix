{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services = {
    xserver = {
      enable = true;
      xkb.layout = "us,ara";
      desktopManager.xterm.enable = false;
      excludePackages = [ pkgs.xterm ];
    };

    # Enable udisks2 and gvfs so file managers can auto-detect and mount disks
    gvfs.enable = true;
    udisks2.enable = true;
    tumbler.enable = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

  systemd.user.services.xdg-desktop-portal-gnome.wantedBy = [ "graphical-session.target" ];
  systemd.user.services.xdg-desktop-portal-gtk.wantedBy = [ "graphical-session.target" ];

  programs.niri.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
  };

  fonts = {
    packages = [
      pkgs.nerd-fonts.jetbrains-mono
      pkgs.nerd-fonts.fira-code
      pkgs."kawkab-mono-font"
    ];
    fontconfig.defaultFonts.monospace = [
      "JetBrainsMono Nerd Font"
      "Kawkab Mono"
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [
          "gnome"
          "gtk"
        ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
      };
    };
  };
}
