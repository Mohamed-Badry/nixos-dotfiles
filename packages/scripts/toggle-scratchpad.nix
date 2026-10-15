{
  writeShellScriptBin,
  lib,
  jq,
  niri,
  wezterm,
  zellij,
}:
writeShellScriptBin "toggle-scratchpad" ''
  export PATH="${
    lib.makeBinPath [
      jq
      niri
      wezterm
      zellij
    ]
  }:$PATH"
  window_json=$(niri msg -j windows | jq -r '.[] | select(.app_id == "scratchpad")' 2>/dev/null)
  if [ -z "$window_json" ]; then
    wezterm start --class scratchpad -- zellij --layout dev attach -c scratchpad
  else
    window_id=$(printf '%s' "$window_json" | jq -r '.id')
    focused=$(printf '%s' "$window_json" | jq -r '.is_focused')
    if [ "$focused" = true ]; then
      niri msg action close-window --id "$window_id"
    else
      niri msg action focus-window --id "$window_id"
    fi
  fi
''
