{ pkgs, lib, ... }:
let
  qylock = pkgs.callPackage ../../../packages/qylock.nix { };
  gstreamerPlugins = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];
in
{
  boot.plymouth = {
    enable = true;
    theme = "hexa_retro";
    themePackages = [ (pkgs.callPackage ../../../packages/plymouth-theme.nix { }) ];
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services = {
    sddm.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sword";
    package = pkgs.kdePackages.sddm;
    settings.Wayland.GreeterEnvironment = "QT_MEDIA_BACKEND=gstreamer,GST_PLUGIN_SYSTEM_PATH_1_0=${
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstreamerPlugins
    }";
    extraPackages = [
      qylock.sddmTheme
      pkgs.kdePackages.qt5compat
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtsvg
    ]
    ++ gstreamerPlugins;
  };

  environment.systemPackages = [
    qylock.lock
    qylock.sddmTheme
  ];
}
