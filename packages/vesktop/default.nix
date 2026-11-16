{
  symlinkJoin,
  vesktop,
  writeShellScript,
  raise-or-run,
  jq,
  coreutils,
  gawk,
}:
let
  wrapper = writeShellScript "vesktop" ''
    CONFIG_DIR="$HOME/.config/vesktop/settings"
    CONFIG="$CONFIG_DIR/settings.json"
    QUICK_CSS="$CONFIG_DIR/quickCss.css"

    mkdir -p "$CONFIG_DIR"
    if [ ! -f "$CONFIG" ]; then
      echo '{"plugins":{}}' > "$CONFIG"
    fi

    BIRTH=$(${coreutils}/bin/stat -c %W / 2>/dev/null || true)
    if [ -z "$BIRTH" ] || [ "$BIRTH" = "0" ] || [ "$BIRTH" -le 0 ] 2>/dev/null; then
      BIRTH=1784085207
    fi
    START_MS="$((BIRTH * 1000))"

    ${jq}/bin/jq \
      --argjson start "$START_MS" \
      '.useQuickCss = true
      | .plugins.CustomRPC = (.plugins.CustomRPC // {}) * {
        "enabled": true,
        "enablePresence": true,
        "type": 0,
        "appID": "1342654397354676316",
        "appName": "NixOS",
        "details": "flake.nix",
        "state": "",
        "imageBig": "https://avatars.githubusercontent.com/u/487568",
        "imageBigURL": "https://nixos.org",
        "imageBigTooltip": "NixOS",
        "timestampMode": 3,
        "startTime": $start
      }' "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"

    if [ -f "$QUICK_CSS" ]; then
      ${gawk}/bin/awk '
        /\/\* vesktop-font-fallback:start \*\// { skip = 1; next }
        /\/\* vesktop-font-fallback:end \*\// { skip = 0; next }
        !skip { print }
      ' "$QUICK_CSS" > "$QUICK_CSS.tmp"
      # Collapse trailing blank lines left behind when stripping an older block.
      ${gawk}/bin/awk '{ lines[NR] = $0 } /[^[:space:]]/ { last = NR } END { for (i = 1; i <= last; i++) print lines[i] }' \
        "$QUICK_CSS.tmp" > "$QUICK_CSS.clean"
      rm -f "$QUICK_CSS.tmp"
      mv "$QUICK_CSS.clean" "$QUICK_CSS.tmp"
    else
      : > "$QUICK_CSS.tmp"
    fi

    cat >> "$QUICK_CSS.tmp" <<'EOF'
    /* vesktop-font-fallback:start */
    :root body {
      --font: 'figtree';
    }
    /* vesktop-font-fallback:end */
    EOF
    mv "$QUICK_CSS.tmp" "$QUICK_CSS"

    exec ${raise-or-run}/bin/raise-or-run vesktop ${vesktop}/bin/vesktop "$@"
  '';
in
symlinkJoin {
  name = "vesktop";
  paths = [ vesktop ];
  postBuild = ''
    rm -f $out/bin/vesktop
    cp ${wrapper} $out/bin/vesktop
  '';
}
