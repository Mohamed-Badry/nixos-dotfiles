{ pkgs, ... }:
{
  home.packages = [ pkgs.noctalia-shell ];

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
