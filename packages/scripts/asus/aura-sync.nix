{ writeShellScriptBin, callPackage }:
let
  asusControlLib = callPackage ./lib.nix { };
in
writeShellScriptBin "asus-aura-sync" ''
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

  apply_aura "$mode" "$color" "$secondary_color" >/dev/null 2>&1 || true

  niri msg action reload-config >/dev/null 2>&1 || true
''
