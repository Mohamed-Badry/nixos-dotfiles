{ ... }:
{
  fileSystems."/media/crim/grind" = {
    device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
    fsType = "btrfs";
    options = [
      "subvol=@grind"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/media/crim/productivity" = {
    device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
    fsType = "btrfs";
    options = [
      "subvol=@productivity"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/media/crim/popos" = {
    device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
    fsType = "btrfs";
    options = [
      "subvol=@popos"
      "compress=zstd"
      "noatime"
      "noauto"
      "x-systemd.automount"
    ];
  };
}
