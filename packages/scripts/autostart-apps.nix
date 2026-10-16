{
  writeShellScriptBin,
  lib,
  jq,
  niri,
  coreutils,
}:
writeShellScriptBin "autostart-apps" ''
  export PATH="${
    lib.makeBinPath [
      coreutils
      jq
      niri
    ]
  }:$PATH"

  # Ensure named workspace indices (1: comms, 2: web, 3: mail)
  niri msg action focus-workspace "comms" 2>/dev/null || true
  niri msg action move-workspace-to-index 1 2>/dev/null || true
  niri msg action focus-workspace "web" 2>/dev/null || true
  niri msg action move-workspace-to-index 2 2>/dev/null || true
  niri msg action focus-workspace "mail" 2>/dev/null || true
  niri msg action move-workspace-to-index 3 2>/dev/null || true

  # Check and launch zapfast on workspace "comms"
  if ! niri msg -j windows 2>/dev/null | jq -e '.[] | select(.app_id == "zapfast")' >/dev/null 2>&1; then
    zapfast &
    sleep 0.8
  fi

  # Check and launch vesktop on workspace "comms" (tiled to the right of zapfast)
  if ! niri msg -j windows 2>/dev/null | jq -e '.[] | select(.app_id == "vesktop")' >/dev/null 2>&1; then
    vesktop &
    sleep 0.8
  fi

  # Check and launch mailspring on workspace "mail"
  if ! niri msg -j windows 2>/dev/null | jq -e '.[] | select(.app_id | test("(?i)mailspring"))' >/dev/null 2>&1; then
    mailspring &
    sleep 0.8
  fi

  # Check and launch zen on workspace "web"
  if ! niri msg -j windows 2>/dev/null | jq -e '.[] | select(.app_id == "zen")' >/dev/null 2>&1; then
    zen &
    sleep 1
  fi

  # Ensure focus lands on web workspace
  niri msg action focus-workspace "web" 2>/dev/null || true
''
