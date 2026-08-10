{ pkgs }:
let
  asusControlPath = pkgs.lib.makeBinPath (
    with pkgs;
    [
      asusctl
      coreutils
      gnugrep
      gnused
      imagemagick
      jq
      libnotify
      noctalia-shell
      python3
    ]
  );

  asusControlLib = ''
        export PATH="${asusControlPath}:$PATH"

        if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
          export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        fi

        if [ -z "''${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -S "$XDG_RUNTIME_DIR/bus" ]; then
          export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        fi

        state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/asus-aura"
    color_file="$state_dir/color"
    secondary_color_file="$state_dir/secondary-color"
    mode_file="$state_dir/mode"
    profile_file="$state_dir/profile"
    log_file="$state_dir/asus-control.log"

        mkdir -p "$state_dir"

        log_asus() {
          printf '%s %s\n' "$(date --iso-8601=seconds)" "$*" >> "$log_file"
        }

        is_hex_color() {
          printf '%s' "$1" | grep -Eiq '^[0-9a-f]{6}$'
        }

        normalize_color() {
          color=$(printf '%s' "$1" | sed 's/^#//' | tr '[:upper:]' '[:lower:]')
          if is_hex_color "$color"; then
            printf '%s\n' "$color"
            return 0
          fi
          return 1
        }

        noctalia_color() {
          key="$1"
          colors_file="''${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/colors.json"
          [ -f "$colors_file" ] || return 1

          color=$(jq -er --arg key "$key" '.[$key] // empty' "$colors_file" 2>/dev/null | head -n 1) || return 1
          normalize_color "$color"
        }

        wallpaper_color() {
          wallpaper="''${1:-}"
          [ -n "$wallpaper" ] || return 1
          [ -f "$wallpaper" ] || return 1

          color=$(magick "$wallpaper" -auto-orient -resize '1x1!' -depth 8 -format '%[hex:p{0,0}]' info: 2>/dev/null) || return 1
          normalize_color "$color"
        }

        led_color() {
          color=$(normalize_color "$1") || return 1

          python3 - "$color" <<'PY'
    import colorsys
    import sys

    hex_color = sys.argv[1]
    r = int(hex_color[0:2], 16) / 255
    g = int(hex_color[2:4], 16) / 255
    b = int(hex_color[4:6], 16) / 255

    h, lightness, saturation = colorsys.rgb_to_hls(r, g, b)

    # Material/Noctalia colors are good UI colors, but laptop RGB LEDs wash out
    # high-lightness pastels. Preserve hue; force saturation and LED-safe lightness.
    saturation = max(saturation, 0.78)
    lightness = min(max(lightness, 0.38), 0.50)

    r, g, b = colorsys.hls_to_rgb(h, lightness, saturation)
    print(f"{round(r * 255):02x}{round(g * 255):02x}{round(b * 255):02x}")
    PY
        }

        pick_primary_color() {
          wallpaper="''${1:-}"

          color=$(noctalia_color mPrimary 2>/dev/null || true)
          if is_hex_color "''${color:-}"; then
            printf '%s\n' "$color"
            return 0
          fi

          color=$(wallpaper_color "$wallpaper" 2>/dev/null || true)
          if is_hex_color "''${color:-}"; then
            printf '%s\n' "$color"
            return 0
          fi

          printf '%s\n' "97cbff"
        }

    pick_secondary_color() {
      printf '%s\n' "000000"
    }

    active_profile() {
      asusctl profile get 2>/dev/null \
        | sed -n 's/^Active profile:[[:space:]]*//p' \
        | head -n 1
    }

    aura_mode_uses_color() {
      case "$1" in
        static | breathe | stars | highlight | laser | ripple | pulse | comet | flash)
          return 0
          ;;
        *)
          return 1
          ;;
      esac
    }

    aura_mode_body() {
      mode="$1"
      color="$2"

      if aura_mode_uses_color "$mode"; then
        printf 'Mode: %s (#%s)\n' "$mode" "$color"
      else
        printf 'Mode: %s\n' "$mode"
      fi
    }

        notify_asus() {
          title="$1"
          body="$2"
          type="''${3:-notice}"
          payload=$(jq -nc \
            --arg title "$title" \
            --arg body "$body" \
            --arg type "$type" \
            '{title: $title, body: $body, type: $type, duration: 2500}')

          if noctalia-shell ipc --any-display call toast send "$payload" >/dev/null 2>&1; then
            log_asus "toast sent through noctalia: $title - $body"
            return 0
          fi

          if notify-send -a "ASUS Control" "$title" "$body" >/dev/null 2>&1; then
            log_asus "toast sent through notify-send: $title - $body"
            return 0
          fi

          log_asus "toast failed: $title - $body"
          return 0
        }

        apply_aura() {
          mode="$1"
          color="$2"
          secondary_color="$3"

          case "$mode" in
            static)
              asusctl aura effect static -c "$color"
              ;;
        breathe)
          asusctl aura effect breathe --colour "$color" --colour2 "$secondary_color" --speed med
          ;;
        rainbow-cycle)
          asusctl aura effect rainbow-cycle --speed med
          ;;
        rainbow-wave)
          asusctl aura effect rainbow-wave --direction right --speed med
          ;;
        stars)
          asusctl aura effect stars --colour "$color" --colour2 "$secondary_color" --speed med
          ;;
        rain)
          asusctl aura effect rain --speed med
          ;;
        highlight)
          asusctl aura effect highlight -c "$color" --speed med
          ;;
        laser)
          asusctl aura effect laser -c "$color" --speed med
          ;;
        ripple)
          asusctl aura effect ripple -c "$color" --speed med
          ;;
        pulse)
          asusctl aura effect pulse -c "$color"
          ;;
        comet)
          asusctl aura effect comet -c "$color"
          ;;
        flash)
          asusctl aura effect flash -c "$color"
          ;;
            *)
              printf 'Unsupported Aura mode: %s\n' "$mode" >&2
              return 2
              ;;
          esac
        }
  '';
in
{
  smartPlayerctl = pkgs.writeShellScriptBin "smart-playerctl" ''
    export PATH="${
      pkgs.lib.makeBinPath (
        with pkgs;
        [
          playerctl
          libnotify
          coreutils
          gnugrep
        ]
      )
    }:$PATH"
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
      echo "''${players[$next]}" > "$state_file"
      notify-send "Player Switched" "Active: ''${players[$next]}"
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
  '';

  toggleScratchpad = pkgs.writeShellScriptBin "toggle-scratchpad" ''
    export PATH="${
      pkgs.lib.makeBinPath (
        with pkgs;
        [
          jq
          niri
          wezterm
          zellij
        ]
      )
    }:$PATH"
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

  asusProfileSwitch = pkgs.writeShellScriptBin "asus-profile-switch" ''
    ${asusControlLib}

    if ! output=$(asusctl profile next 2>&1); then
      notify_asus "ASUS Power Profile" "$output" "error"
      exit 1
    fi

    sleep 0.2

    profile=$(
      asusctl profile get 2>/dev/null \
        | sed -n 's/^Active profile:[[:space:]]*//p' \
        | head -n 1
    )

    if [ -z "$profile" ]; then
      profile=$(
        asusctl profile get 2>/dev/null \
          | sed '/^[[:space:]]*$/d' \
          | tail -n 1 \
          | sed 's/.*:[[:space:]]*//'
      )
    fi

    [ -n "$profile" ] || profile="unknown"
    notify_asus "ASUS Power Profile" "Switched to: $profile"
  '';

  asusAuraSync = pkgs.writeShellScriptBin "asus-aura-sync" ''
    ${asusControlLib}

    wallpaper="''${1:-}"
    source_color=$(pick_primary_color "$wallpaper")
    color=$(led_color "$source_color")
    secondary_color=$(pick_secondary_color)
    mode=$(cat "$mode_file" 2>/dev/null || printf '%s\n' static)

    case "$mode" in
      static | breathe | pulse | rainbow-cycle | rainbow-wave) ;;
      *) mode=static ;;
    esac

    printf '%s\n' "$color" > "$color_file"
    printf '%s\n' "$secondary_color" > "$secondary_color_file"

    if ! output=$(apply_aura "$mode" "$color" "$secondary_color" 2>&1); then
      notify_asus "ASUS Aura" "$output" "error"
      exit 1
    fi
  '';

  asusAuraMode = pkgs.writeShellScriptBin "asus-aura-mode" ''
    ${asusControlLib}

    action="''${1:-next}"
    current_mode=$(cat "$mode_file" 2>/dev/null || printf '%s\n' static)

    case "$action" in
      next)
        case "$current_mode" in
          static) mode=breathe ;;
          breathe) mode=pulse ;;
          pulse) mode=rainbow-cycle ;;
          rainbow-cycle) mode=rainbow-wave ;;
          rainbow-wave) mode=static ;;
          *) mode=static ;;
        esac
        ;;
      prev)
        case "$current_mode" in
          static) mode=rainbow-wave ;;
          breathe) mode=static ;;
          pulse) mode=breathe ;;
          rainbow-cycle) mode=pulse ;;
          rainbow-wave) mode=rainbow-cycle ;;
          *) mode=static ;;
        esac
        ;;
      static | breathe | pulse | rainbow-cycle | rainbow-wave)
        mode="$action"
        ;;
      *)
        printf 'Usage: asus-aura-mode [next|prev|static|breathe|pulse|rainbow-cycle|rainbow-wave]\n' >&2
        exit 2
        ;;
    esac

    if [ -f "$color_file" ]; then
      color=$(cat "$color_file" 2>/dev/null || true)
    else
      color=$(led_color "$(pick_primary_color "")")
    fi

    secondary_color=$(cat "$secondary_color_file" 2>/dev/null || pick_secondary_color)

    if ! is_hex_color "$color"; then
      color=$(led_color "$(pick_primary_color "")")
    fi

    if ! is_hex_color "$secondary_color"; then
      secondary_color=$(pick_secondary_color)
    fi

    if ! output=$(apply_aura "$mode" "$color" "$secondary_color" 2>&1); then
      notify_asus "ASUS Aura" "$output" "error"
      exit 1
    fi

    printf '%s\n' "$mode" > "$mode_file"
    printf '%s\n' "$color" > "$color_file"
    printf '%s\n' "$secondary_color" > "$secondary_color_file"

    notify_asus "ASUS Aura" "Mode: $mode (#$color)"
  '';
}
