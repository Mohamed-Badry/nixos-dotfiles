{
  writeShellScriptBin,
  lib,
  niri,
  jq,
}:
writeShellScriptBin "focus-zen" ''
  export PATH="${lib.makeBinPath [ niri jq ]}:$PATH"

  win_id=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select(.app_id == "zen") | .id' | head -n1)
  if [ -n "$win_id" ]; then
    exec niri msg action focus-window --id "$win_id"
  else
    exec zen "$@"
  fi
''
