{ writeShellScriptBin, callPackage }:
let
  asusControlLib = callPackage ./lib.nix { };
in
writeShellScriptBin "asus-aura-mode" ''
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
    notify_asus "ASUS Aura" "$output"
    exit 1
  fi

  printf '%s\n' "$mode" > "$mode_file"
  printf '%s\n' "$color" > "$color_file"
  printf '%s\n' "$secondary_color" > "$secondary_color_file"

  notify_asus "ASUS Aura" "$(aura_mode_body "$mode" "$color")"
''
