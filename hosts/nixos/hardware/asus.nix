_: {
  services.asusd = {
    enable = true;
  };

  # Blacklist troublesome MediaTek Wi-Fi kernel module
  boot.blacklistedKernelModules = [ "mt7921e" ];

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
