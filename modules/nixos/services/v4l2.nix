{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.v4l-utils ];

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="video4linux", ATTR{index}=="0", RUN+="${pkgs.v4l-utils}/bin/v4l2-ctl -d $devnode -c power_line_frequency=1"
  '';

  powerManagement.resumeCommands = ''
    ${pkgs.v4l-utils}/bin/v4l2-ctl -d /dev/video0 -c power_line_frequency=1 || true
  '';
}
