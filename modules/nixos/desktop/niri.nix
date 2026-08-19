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

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # Enable udisks2 and gvfs so file managers can auto-detect and mount disks
    gvfs.enable = true;
    udisks2.enable = true;
  };

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
      common.default = [ "gtk" ];
      niri.default = [
        "gnome"
        "gtk"
      ];
    };
  };
}
