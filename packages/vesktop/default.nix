{
  symlinkJoin,
  vesktop,
  writeShellScript,
  niri,
  jq,
}:
let
  wrapper = writeShellScript "vesktop" ''
    win_id=$(${niri}/bin/niri msg -j windows 2>/dev/null | ${jq}/bin/jq -r '.[] | select(.app_id == "vesktop") | .id' | head -n1)
    if [ -n "$win_id" ]; then
      exec ${niri}/bin/niri msg action focus-window --id "$win_id"
    else
      exec ${vesktop}/bin/vesktop "$@"
    fi
  '';
in
symlinkJoin {
  name = "vesktop";
  paths = [ vesktop ];
  postBuild = ''
    rm -f $out/bin/vesktop
    cp ${wrapper} $out/bin/vesktop
  '';
}
