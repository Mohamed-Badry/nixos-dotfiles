{ writeShellScriptBin, yt-dlp }:
writeShellScriptBin "yt-dlp" ''
  args=()
  for arg in "$@"; do
    if [ "$arg" = "bestaudio" ]; then
      args+=("bestaudio/best")
    else
      args+=("$arg")
    fi
  done
  exec "${yt-dlp}/bin/yt-dlp" "''${args[@]}"
''
