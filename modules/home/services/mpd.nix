{
  config,
  pkgs,
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
      audio_output {
        type "pipewire"
        name "PipeWire Sound Server"
      }
    '';
  };
  services.mpd-mpris.enable = true;
}
