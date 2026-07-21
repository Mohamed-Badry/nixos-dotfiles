{ pkgs }:
{
  smartPlayerctl = pkgs.writeShellScriptBin "smart-playerctl" ''
    export PATH="${pkgs.lib.makeBinPath (with pkgs; [ playerctl libnotify coreutils gnugrep ])}:$PATH"
    command="$1"
      state_file="$HOME/.local/state/smart-playerctl-last"
      mkdir -p "$(dirname "$state_file")"

      if [ "$command" = switch ] || [ "$command" = cycle ]; then
        mapfile -t players < <(playerctl --list-all 2>/dev/null)
        count=''${#players[@]}
        [ "$count" -gt 0 ] || { notify-send "Player Control" "No players found"; exit 0; }
        current=$(cat "$state_file" 2>/dev/null || true)
        next=0
        for i in "''${!players[@]}"; do
          [ "''${players[$i]}" = "$current" ] && next=$(( (i + 1) % count ))
        done
        printf '%s\\n' "''${players[$next]}" > "$state_file"
        notify-send "Player Switched" "Active: ''${players[$next]}"
        exit 0
      fi

      playing=$(playerctl --list-all 2>/dev/null | while read -r player; do
        [ "$(playerctl -p "$player" status 2>/dev/null)" = Playing ] && printf '%s\\n' "$player"
      done)
      if [ -n "$playing" ]; then
        target=$(printf '%s\\n' "$playing" | head -n 1)
        printf '%s\\n' "$target" > "$state_file"
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
    '';

  toggleScratchpad = pkgs.writeShellScriptBin "toggle-scratchpad" ''
    export PATH="${pkgs.lib.makeBinPath (with pkgs; [ jq niri wezterm zellij ])}:$PATH"
    window_json=$(niri msg -j windows | jq -r '.[] | select(.app_id == "scratchpad")' 2>/dev/null)
      if [ -z "$window_json" ]; then
        wezterm start --class scratchpad -- zellij --layout zj_dev attach -c scratchpad
      else
        window_id=$(printf '%s' "$window_json" | jq -r '.id')
        focused=$(printf '%s' "$window_json" | jq -r '.is_focused')
        if [ "$focused" = true ]; then
          niri msg action close-window --id "$window_id"
        else
          niri msg action focus-window --id "$window_id"
        fi
      fi
    '';

  obsToggleRecord =
    pkgs.writers.writePython3Bin "obs-toggle-record"
      {
        libraries = [ pkgs.python3Packages.obsws-python ];
      }
      ''
        import os
        import sys
        import obsws_python as obs

        password = os.environ.get("OBS_PASSWORD")
        if not password:
            path = os.path.expanduser(
                "~/.config/obs-studio/obs-websocket-password.txt"
            )
            try:
                with open(path, encoding="utf-8") as password_file:
                    password = password_file.read().strip()
            except FileNotFoundError:
                sys.exit(
                    "OBS_PASSWORD is unset and no websocket password file exists"
                )

        client = obs.ReqClient(
            host="localhost", port=4455, password=password
        )
        client.toggle_record()
      '';
}
