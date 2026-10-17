{
  writeShellScriptBin,
  lib,
  niri,
  jq,
  coreutils,
}:
writeShellScriptBin "raise-or-run" ''
  export PATH="${lib.makeBinPath [ niri jq coreutils ]}:$PATH"

  minimize_method="auto"

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --close)
        minimize_method="close"
        shift
        ;;
      --previous)
        minimize_method="previous"
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  if [ "$#" -lt 1 ]; then
    echo "Usage: raise-or-run [--close|--previous] <app-id> [command] [args...]" >&2
    exit 1
  fi

  app_id="$1"
  shift

  if [ "$#" -eq 0 ]; then
    set -- "$app_id"
  fi

  win_info=$(niri msg -j windows 2>/dev/null | jq -r --arg id "$app_id" '.[] | select((.app_id // "" | ascii_downcase) == ($id | ascii_downcase)) | "\(.id) \(.is_focused)"' | head -n1)

  if [ -n "$win_info" ]; then
    read -r win_id is_focused <<< "$win_info"

    if [ "$is_focused" = "true" ]; then
      if [ "$minimize_method" = "close" ]; then
        niri msg action focus-window-previous 2>/dev/null || true
        exec niri msg action close-window --id "$win_id"
      elif [ "$minimize_method" = "previous" ]; then
        exec niri msg action focus-window-previous
      else
        app_lower=$(echo "$app_id" | tr '[:upper:]' '[:lower:]')
        case "$app_lower" in
          mailspring|vesktop|zapfast|scratchpad)
            niri msg action focus-window-previous 2>/dev/null || true
            exec niri msg action close-window --id "$win_id"
            ;;
          *)
            exec niri msg action focus-window-previous
            ;;
        esac
      fi
    else
      exec niri msg action focus-window --id "$win_id"
    fi
  else
    exec "$@"
  fi
''
