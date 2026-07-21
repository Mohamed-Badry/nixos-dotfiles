{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
    ./boot.nix
    ./hardware/nvidia.nix
    ./user.nix
  ];
}
