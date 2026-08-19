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

  services.udev.extraHwdb = ''
    evdev:name:Asus WMI hotkeys:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
      KEYBOARD_KEY_b2=kbdillumdown
      KEYBOARD_KEY_00b2=kbdillumdown
      KEYBOARD_KEY_b3=kbdillumup
      KEYBOARD_KEY_00b3=kbdillumup
  '';

  # Fix ALC256 combo jack headset microphone on ASUS laptops
  boot.extraModprobeConfig = "options snd-hda-intel model=dell-headset-multi";
}
