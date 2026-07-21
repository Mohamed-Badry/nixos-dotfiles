{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.noctalia-shell ];

  home.activation.copyNoctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p $HOME/.config/noctalia
    rm -f $HOME/.config/noctalia/colors.json $HOME/.config/noctalia/plugins.json $HOME/.config/noctalia/settings.json
    cp ${../../../config/noctalia/colors.json} $HOME/.config/noctalia/colors.json
    cp ${../../../config/noctalia/plugins.json} $HOME/.config/noctalia/plugins.json
    cp ${../../../config/noctalia/settings.json} $HOME/.config/noctalia/settings.json
    chmod u+w $HOME/.config/noctalia/*.json
  '';
}
