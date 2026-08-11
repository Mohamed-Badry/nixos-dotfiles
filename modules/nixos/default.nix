{ ... }:
{
  imports = [
    ./base
    ./base/packages.nix
    ./desktop/niri.nix
    ./services/keyd.nix
    ./services/sddm-qylock.nix
    ./services/perfmode.nix
  ];
}
