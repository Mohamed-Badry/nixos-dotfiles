{
  symlinkJoin,
  mailspring,
  writeShellScript,
  raise-or-run,
}:
let
  wrapper = writeShellScript "mailspring" ''
    exec ${raise-or-run}/bin/raise-or-run mailspring ${mailspring}/bin/mailspring --password-store=gnome-libsecret "$@"
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
