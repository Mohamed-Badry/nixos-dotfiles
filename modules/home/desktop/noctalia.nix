{
  config,
  pkgs,
  lib,
  ...
}:
let
  scripts = pkgs.callPackage ../../../packages/scripts.nix { };
  settings = pkgs.writeText "noctalia-settings.json" (
    builtins.replaceStrings
      [
        "@HOME@"
        "@ASUS_AURA_SYNC@"
      ]
      [
        config.home.homeDirectory
        "${scripts.asusAuraSync}/bin/asus-aura-sync"
      ]
      (builtins.readFile ../../../config/noctalia/settings.json)
  );
in
{
  home.packages = [
    pkgs.noctalia-shell
    scripts.asusAuraSync
  ];

  home.activation.copyNoctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/noctalia"
    install -m 0644 ${../../../config/noctalia/colors.json} "$HOME/.config/noctalia/colors.json"
    install -m 0644 ${../../../config/noctalia/plugins.json} "$HOME/.config/noctalia/plugins.json"
    install -m 0644 ${settings} "$HOME/.config/noctalia/settings.json"
    chmod u+w "$HOME"/.config/noctalia/*.json
  '';
}
