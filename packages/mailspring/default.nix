{
  symlinkJoin,
  mailspring,
  makeWrapper,
}:
symlinkJoin {
  name = "mailspring";
  paths = [ mailspring ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/mailspring \
      --add-flags "--password-store=gnome-libsecret"

    rm -f $out/share/applications/Mailspring.desktop
    substitute ${mailspring}/share/applications/Mailspring.desktop $out/share/applications/Mailspring.desktop \
      --replace-fail "${mailspring}/bin/mailspring" "$out/bin/mailspring"
  '';
}
