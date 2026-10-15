{
  lib,
  asusctl,
  coreutils,
  gnugrep,
  gnused,
  imagemagick,
  jq,
  libnotify,
  python3,
}:
let
  asusControlPath = lib.makeBinPath [
    asusctl
    coreutils
    gnugrep
    gnused
    imagemagick
    jq
    libnotify
    python3
  ];
in
''
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
      local color=""
      if [ -f "$HOME/.config/niri/noctalia.kdl" ]; then
        color=$(grep -m1 'active-color' "$HOME/.config/niri/noctalia.kdl" 2>/dev/null | sed -E 's/.*"#(.*)".*/\1/')
      fi
      if [ -z "$color" ] && [ -f "$HOME/.config/wezterm/colors/Noctalia.toml" ]; then
        color=$(grep -m1 'bg_color' "$HOME/.config/wezterm/colors/Noctalia.toml" 2>/dev/null | sed -E 's/.*"#(.*)".*/\1/')
      fi
      if is_hex_color "''${color:-}"; then
        normalize_color "$color"
        return 0
      fi
      return 1
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
      notify-send -u critical -h string:category:system -t 1200 -a "ASUS Control" "$title" "$body" >/dev/null 2>&1 || true
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
''
