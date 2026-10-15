{
  writeShellScriptBin,
  lib,
  playerctl,
  libnotify,
  coreutils,
  gnugrep,
}:
writeShellScriptBin "smart-playerctl" ''
  export PATH="${
    lib.makeBinPath [
      playerctl
      libnotify
      coreutils
      gnugrep
    ]
  }:$PATH"
  command="$1"
  state_file="$HOME/.local/state/smart-playerctl-last"
  mkdir -p "$(dirname "$state_file")"

  if [ "$command" = switch ] || [ "$command" = cycle ]; then
    mapfile -t players < <(playerctl --list-all 2>/dev/null)
    count=''${#players[@]}
    [ "$count" -gt 0 ] || { notify-send -u critical -h string:category:system -t 1200 "Player Control" "No players found"; exit 0; }
    current=$(cat "$state_file" 2>/dev/null || true)
    next=0
    for i in "''${!players[@]}"; do
      [ "''${players[$i]}" = "$current" ] && next=$(( (i + 1) % count ))
    done
    echo "''${players[$next]}" > "$state_file"
    notify-send -u critical -h string:category:system -t 1200 "Player Switched" "Active: ''${players[$next]}"
    exit 0
  fi

  playing=$(playerctl --list-all 2>/dev/null | while read -r player; do
    [ "$(playerctl -p "$player" status 2>/dev/null)" = Playing ] && echo "$player"
  done)
  if [ -n "$playing" ]; then
    target=$(echo "$playing" | head -n 1)
    echo "$target" > "$state_file"
    playerctl --player="$target" "$command"
  else
    if [ -f "$state_file" ]; then
      last_player=$(cat "$state_file")
      if playerctl --list-all 2>/dev/null | grep -Fxq "$last_player"; then
        playerctl --player="$last_player" "$command"
        exit 0
      fi
    fi
    playerctl "$command"
  fi
''
