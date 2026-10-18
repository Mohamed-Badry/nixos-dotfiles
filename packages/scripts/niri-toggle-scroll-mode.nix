{
  writeShellScriptBin,
  lib,
  niri,
  libnotify,
  coreutils,
  gnugrep,
}:
writeShellScriptBin "niri-toggle-scroll-mode" ''
  export PATH="${
    lib.makeBinPath [
      niri
      libnotify
      coreutils
      gnugrep
    ]
  }:$PATH"

  CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/niri"
  TARGET_FILE="$CONFIG_DIR/scroll-mode.kdl"

  mkdir -p "$CONFIG_DIR"

  if [ -f "$TARGET_FILE" ] && grep -q '"always"' "$TARGET_FILE"; then
    printf 'layout {\n    center-focused-column "never"\n}\n' > "$TARGET_FILE"
    niri msg action load-config-file
    notify-send -h string:category:system -a "Niri" -t 2000 "Scrolling Mode" "Edge-aligned (Never center)"
  else
    printf 'layout {\n    center-focused-column "always"\n}\n' > "$TARGET_FILE"
    niri msg action load-config-file
    niri msg action center-column
    notify-send -h string:category:system -a "Niri" -t 2000 "Scrolling Mode" "Carousel (Always center)"
  fi
''
