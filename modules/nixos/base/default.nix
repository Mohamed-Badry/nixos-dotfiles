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
    keep-outputs = true;
    keep-derivations = true;
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

  # Fix ALC256 combo jack headset microphone on ASUS laptops
  boot.extraModprobeConfig = "options snd-hda-intel model=dell-headset-multi";
}
