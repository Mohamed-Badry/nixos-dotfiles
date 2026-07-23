{ username, ... }:
{
  fileSystems = {
    "/media/${username}/grind" = {
      device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
      fsType = "btrfs";
      options = [
        "subvol=@grind"
        "compress=zstd"
        "noatime"
      ];
    };

    "/media/${username}/productivity" = {
      device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
      fsType = "btrfs";
      options = [
        "subvol=@productivity"
        "compress=zstd"
        "noatime"
      ];
    };

    "/media/${username}/popos" = {
      device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
      fsType = "btrfs";
      options = [
        "subvol=@popos"
        "compress=zstd"
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-gvfs-show"
        "x-gvfs-name=Pop_OS"
      ];
    };
  };
}
