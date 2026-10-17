{
  writeShellScriptBin,
  raise-or-run,
}:
writeShellScriptBin "focus-zen" ''
  exec ${raise-or-run}/bin/raise-or-run zen zen "$@"
''
