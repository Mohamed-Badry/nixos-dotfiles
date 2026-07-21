{ pkgs, ... }:
{
  home.packages = [ pkgs.noctalia-shell ];

  xdg.configFile = {
    "noctalia/colors.json".source = ../../../config/noctalia/colors.json;
    "noctalia/plugins.json".source = ../../../config/noctalia/plugins.json;
    "noctalia/settings.json".source = ../../../config/noctalia/settings.json;
  };

  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia shell";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    Service = {
      ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
