{ pkgs, ... }:
{
  services.asusd = {
    enable = true;
  };

  systemd.services.asus-turbo-fan = {
    description = "Set Asus TUF Fan Throttle Policy to Turbo at boot";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ -e /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy ]; then echo 1 > /sys/devices/platform/asus-nb-wmi/throttle_thermal_policy; fi'";
      RemainAfterExit = true;
    };
  };
}
