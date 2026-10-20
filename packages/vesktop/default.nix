{
  symlinkJoin,
  vesktop,
  writeShellScript,
  raise-or-run,
  jq,
  coreutils,
}:
let
  wrapper = writeShellScript "vesktop" ''
    CONFIG_DIR="$HOME/.config/vesktop/settings"
    CONFIG="$CONFIG_DIR/settings.json"

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
      '.plugins.CustomRPC = (.plugins.CustomRPC // {}) * {
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
