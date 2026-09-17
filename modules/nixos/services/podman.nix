{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    # Creates an alias/symlink so 'docker' commands invoke podman
    dockerCompat = true;
    # Enable container name resolution on the default network
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  hardware.nvidia-container-toolkit.enable = true;
}
