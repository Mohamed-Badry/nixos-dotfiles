{
  config,
  pkgs,
  lib,
  ...
}:
let
  settings = pkgs.writeText "noctalia-settings.json" (
    builtins.replaceStrings [ "@HOME@" ] [ config.home.homeDirectory ] (
      builtins.readFile ../../../config/noctalia/settings.json
    )
  );
in
{
  home.packages = [ pkgs.noctalia-shell ];

  home.activation.copyNoctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/noctalia"
    install -m 0644 ${../../../config/noctalia/colors.json} "$HOME/.config/noctalia/colors.json"
    install -m 0644 ${../../../config/noctalia/plugins.json} "$HOME/.config/noctalia/plugins.json"
    install -m 0644 ${settings} "$HOME/.config/noctalia/settings.json"
    chmod u+w "$HOME"/.config/noctalia/*.json
  '';
}
