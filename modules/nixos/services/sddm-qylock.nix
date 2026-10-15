{ pkgs, lib, ... }:
let
  gstreamerPlugins = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];
in
{
  boot.plymouth = {
    enable = true;
    theme = "hexa_retro";
    themePackages = [ pkgs.myPkgs.plymouth-theme ];
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
      pkgs.myPkgs.qylock-sddm-theme
      pkgs.kdePackages.qt5compat
      pkgs.kdePackages.qtmultimedia
      pkgs.kdePackages.qtsvg
    ]
    ++ gstreamerPlugins;
  };

  environment.systemPackages = [
    pkgs.myPkgs.qylock-lock
    pkgs.myPkgs.qylock-sddm-theme
  ];
}
