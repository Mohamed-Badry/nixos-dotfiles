{ hostname, ... }:
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  time.timeZone = "Africa/Cairo";
  i18n.defaultLocale = "en_US.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  system.stateVersion = "26.05";

  # Enable udisks2 and gvfs so file managers can auto-detect and mount disks
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  fileSystems."/media/crim/grind" = {
    device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
    fsType = "btrfs";
    options = [ "subvol=@grind" "compress=zstd" "noatime" ];
  };

  fileSystems."/media/crim/productivity" = {
    device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
    fsType = "btrfs";
    options = [ "subvol=@productivity" "compress=zstd" "noatime" ];
  };

  fileSystems."/media/crim/popos" = {
    device = "/dev/disk/by-uuid/a44ac444-0fa7-404a-a655-9cc05676fa1e";
    fsType = "btrfs";
    options = [ "subvol=@popos" "compress=zstd" "noatime" "noauto" "x-systemd.automount" ];
  };
}
