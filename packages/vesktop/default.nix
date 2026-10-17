{
  symlinkJoin,
  vesktop,
  writeShellScript,
  raise-or-run,
}:
let
  wrapper = writeShellScript "vesktop" ''
    exec ${raise-or-run}/bin/raise-or-run vesktop ${vesktop}/bin/vesktop "$@"
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
