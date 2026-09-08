{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  home.packages = [ pkgs.rmpc ];
  home.file."Music".source = config.lib.file.mkOutOfStoreSymlink "/media/${username}/grind/Music";

  xdg.configFile."rmpc".source = ../../../config/rmpc;

  services.mpd = {
    enable = true;
    musicDirectory = "/media/${username}/grind/Music";
    dataDir = "${config.home.homeDirectory}/.config/mpd";
    extraConfig = ''
      restore_paused "yes"
      bind_to_address "${config.home.homeDirectory}/.config/mpd/socket"
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';
  };
  services.mpd-mpris.enable = true;

  home.sessionVariables = {
    MPD_HOST = lib.mkForce "${config.home.homeDirectory}/.config/mpd/socket";
    MPD_PORT = lib.mkForce "";
  };
  systemd.user.sessionVariables = {
    MPD_HOST = lib.mkForce "${config.home.homeDirectory}/.config/mpd/socket";
    MPD_PORT = lib.mkForce "";
  };
}
