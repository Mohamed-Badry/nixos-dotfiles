{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./boot.nix
    ./hardware/nvidia.nix
    ./hardware/asus.nix
    ./user.nix
  ];
}
