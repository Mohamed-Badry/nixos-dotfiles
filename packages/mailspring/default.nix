{
  symlinkJoin,
  mailspring,
  writeShellScript,
  niri,
  jq,
}:
let
  wrapper = writeShellScript "mailspring" ''
    win_id=$(${niri}/bin/niri msg -j windows 2>/dev/null | ${jq}/bin/jq -r '.[] | select(.app_id | test("(?i)mailspring")) | .id' | head -n1)
    if [ -n "$win_id" ]; then
      exec ${niri}/bin/niri msg action focus-window --id "$win_id"
    else
      exec ${mailspring}/bin/mailspring --password-store=gnome-libsecret "$@"
    fi
  '';
in
symlinkJoin {
  name = "mailspring";
  paths = [ mailspring ];
  postBuild = ''
    rm -f $out/bin/mailspring
    cp ${wrapper} $out/bin/mailspring

    rm -f $out/share/applications/Mailspring.desktop
    cp ${mailspring}/share/applications/Mailspring.desktop $out/share/applications/Mailspring.desktop
    chmod u+w $out/share/applications/Mailspring.desktop
    sed -i "s|${mailspring}/bin/mailspring|$out/bin/mailspring|g" $out/share/applications/Mailspring.desktop
  '';
}
