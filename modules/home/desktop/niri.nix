{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  home.packages = [
    # compositor tools
    pkgs.brightnessctl
    pkgs.hyprpicker
    pkgs.jq
    pkgs.playerctl
    inputs.niri-float-sticky.packages.${pkgs.stdenv.hostPlatform.system}.default

    # niri scripts
    pkgs.myPkgs.autostart-apps
    pkgs.myPkgs.focus-mail
    pkgs.myPkgs.focus-zen
    pkgs.myPkgs.obs-toggle-record
    pkgs.myPkgs.raise-or-run
    pkgs.myPkgs.smart-playerctl
    pkgs.myPkgs.toggle-scratchpad

    # asus controls
    pkgs.myPkgs.asus-aura-mode
    pkgs.myPkgs.asus-aura-sync
    pkgs.myPkgs.asus-profile-switch
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
    "niri/animations.kdl".source = ./niri/animations.kdl;
    "niri/binds.kdl".source = ./niri/binds.kdl;
  };
}
