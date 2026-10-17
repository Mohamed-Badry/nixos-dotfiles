{
  writeShellScriptBin,
  raise-or-run,
}:
writeShellScriptBin "focus-mail" ''
  exec ${raise-or-run}/bin/raise-or-run mailspring mailspring "$@"
''
