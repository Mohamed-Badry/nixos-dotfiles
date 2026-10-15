{ writeShellScriptBin, callPackage }:
let
  asusControlLib = callPackage ./lib.nix { };
in
writeShellScriptBin "asus-profile-switch" ''
  ${asusControlLib}

  if ! output=$(asusctl profile next 2>&1); then
    notify_asus "ASUS Power Profile" "$output"
    exit 1
  fi

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
''
