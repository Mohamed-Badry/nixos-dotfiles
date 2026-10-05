{
  config,
  pkgs,
  lib,
  username,
  ...
}:
{
  home.packages = [ pkgs.rmpc ];

  xdg.configFile."rmpc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/rmpc";

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
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

  systemd.user.services = {
    mpd.Unit.Wants = [ "mpd-mpris.service" ];
    mpd-mpris.Unit.PartOf = [ "mpd.service" ];
  };
  home.sessionVariables = {
    MPD_HOST = lib.mkForce "${config.home.homeDirectory}/.config/mpd/socket";
    MPD_PORT = lib.mkForce "";
  };
  systemd.user.sessionVariables = {
    MPD_HOST = lib.mkForce "${config.home.homeDirectory}/.config/mpd/socket";
    MPD_PORT = lib.mkForce "";
  };
}
