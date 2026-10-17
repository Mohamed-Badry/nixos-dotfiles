{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  home.packages = [
    pkgs.brightnessctl
    pkgs.hyprpicker
    pkgs.jq
    pkgs.playerctl
    inputs.niri-float-sticky.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.myPkgs.smart-playerctl
    pkgs.myPkgs.toggle-scratchpad
    pkgs.myPkgs.obs-toggle-record
    pkgs.myPkgs.asus-profile-switch
    pkgs.myPkgs.asus-aura-sync
    pkgs.myPkgs.asus-aura-mode
    pkgs.myPkgs.autostart-apps
    pkgs.myPkgs.focus-zen
  ];

  home.activation.seedNiriNoctaliaKdl = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/niri/noctalia.kdl" ]; then
      mkdir -p "$HOME/.config/niri"
      touch "$HOME/.config/niri/noctalia.kdl"
    fi
  '';

  xdg.configFile = {
    "niri/config.kdl".source = ./niri/config.kdl;
    "niri/theme.kdl".source = ./niri/theme.kdl;
    "niri/binds.kdl".source = ./niri/binds.kdl;
  };
}
