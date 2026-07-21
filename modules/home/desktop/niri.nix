{ pkgs, inputs, ... }:
let
  scripts = pkgs.callPackage ../../../packages/scripts.nix { };
in
{
  home.packages = [
    pkgs.brightnessctl
    pkgs.hyprpicker
    inputs.niri-float-sticky.packages.${pkgs.stdenv.hostPlatform.system}.default
    scripts.smartPlayerctl
    scripts.toggleScratchpad
    scripts.obsToggleRecord
  ];

  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "niri/theme.kdl".source = ./niri/theme.kdl;
    "niri/binds.kdl".source = ./niri/binds.kdl;
  };
}
