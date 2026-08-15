{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  scripts = pkgs.callPackage ../../../packages/scripts.nix { };
  noctaliaPkg = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  configToml = pkgs.writeText "noctalia-config.toml" (
    builtins.replaceStrings
      [
        "@HOME@"
        "@ASUS_AURA_SYNC@"
      ]
      [
        config.home.homeDirectory
        "${scripts.asusAuraSync}/bin/asus-aura-sync"
      ]
      (builtins.readFile ../../../config/noctalia/config.toml)
  );
in
{
  home.packages = [
    noctaliaPkg
    scripts.asusAuraSync
  ];

  home.activation.copyNoctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/noctalia"
    install -m 0644 ${configToml} "$HOME/.config/noctalia/config.toml"
    chmod u+w "$HOME"/.config/noctalia/config.toml
  '';
}
