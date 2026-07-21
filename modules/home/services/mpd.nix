{
  config,
  pkgs,
  username,
  ...
}:
{
  home.packages = [ pkgs.rmpc ];
  home.file."Music".source = config.lib.file.mkOutOfStoreSymlink "/media/${username}/grind/Music";

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
      audio_output {
        type "fifo"
        name "Visualizer FIFO"
        path "/tmp/mpd.fifo"
        format "44100:16:2"
      }
    '';
  };
  services.mpd-mpris.enable = true;
}
