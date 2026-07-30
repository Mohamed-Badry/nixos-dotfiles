{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = false;
      efi = {
        canTouchEfiVariables = false;
        efiSysMountPoint = "/boot/efi";
      };

      grub = {
        enable = true;
        efiSupport = true;
        # Install the EFI removable-media fallback path; this does not alter NVRAM.
        efiInstallAsRemovable = true;
        configurationLimit = 3;
        device = "nodev";
        useOSProber = false;
        theme = "${
          (pkgs.fetchFromGitHub {
            owner = "semimqmo";
            repo = "sekiro_grub_theme";
            rev = "1affe05f7257b72b69404cfc0a60e88aa19f54a6";
            hash = "sha256-wTr5S/17uwQXkWwElqBKIV1J3QUP6W2Qx2Nw0SaM7Qk=";
          })
        }/Sekiro";
        extraEntries = ''
          menuentry "Pop_OS!" {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root D317-3D5D
            linux /EFI/Pop_OS-a44ac444-0fa7-404a-a655-9cc05676fa1e/vmlinuz.efi root=UUID=a44ac444-0fa7-404a-a655-9cc05676fa1e ro splash systemd.show_status=false loglevel=0 nvidia-drm.modeset=1 quiet fbcon=nodefer usbcore.autosuspend=-1 rootflags=subvol=@popos
            initrd /EFI/Pop_OS-a44ac444-0fa7-404a-a655-9cc05676fa1e/initrd.img
          }
        '';
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;
    blacklistedKernelModules = [ "mt7921e" ];
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };
}
