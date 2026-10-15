{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  configContent =
    builtins.replaceStrings
      [
        "@HOME@"
        "@ASUS_AURA_SYNC@"
      ]
      [
        config.home.homeDirectory
        "${pkgs.myPkgs.asus-aura-sync}/bin/asus-aura-sync"
      ]
      (builtins.readFile ../../../config/noctalia/config.toml);
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    checkConfig = true;
    systemd.enable = true;
    settings = configContent;
  };

  home.packages = [
    pkgs.myPkgs.asus-aura-sync
    pkgs.pulseaudio
    pkgs.bluez
    pkgs.coreutils
  ];

  home.activation.seedNoctaliaConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/noctalia"
    if [ ! -f "$HOME/.config/noctalia/settings.json" ]; then
      sed "s|@HOME@|$HOME|g; s|@ASUS_AURA_SYNC@|asus-aura-sync|g" ${../../../config/noctalia/settings.json} > "$HOME/.config/noctalia/settings.json"
      chmod 0644 "$HOME/.config/noctalia/settings.json"
    else
      sed -i "s|@HOME@|$HOME|g; s|@ASUS_AURA_SYNC@|asus-aura-sync|g" "$HOME/.config/noctalia/settings.json"
    fi
    if [ ! -f "$HOME/.config/noctalia/colors.json" ]; then
      cp -f ${../../../config/noctalia/colors.json} "$HOME/.config/noctalia/colors.json"
      chmod 0644 "$HOME/.config/noctalia/colors.json"
    fi
    if [ ! -f "$HOME/.config/noctalia/plugins.json" ]; then
      cp -f ${../../../config/noctalia/plugins.json} "$HOME/.config/noctalia/plugins.json"
      chmod 0644 "$HOME/.config/noctalia/plugins.json"
    fi
  '';
}
