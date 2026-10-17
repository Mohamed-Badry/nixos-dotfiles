{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  libxkbcommon,
  wayland,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  raise-or-run,
}:
let
  version = "0.19.0";
  runtimeLibs = [
    alsa-lib
    libxkbcommon
    wayland
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
  ];
in
stdenv.mkDerivation {
  pname = "zapfast";
  inherit version;

  src = fetchurl {
    url = "https://github.com/crmne/zapfast/releases/download/v${version}/zapfast-v${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-DKx8fdoTJiZcmhbcxWK6bQe9C4rl1TTzUpt4Z2ADZmM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 zapfast $out/bin/.zapfast-unwrapped
    install -Dm644 packaging/applications/zapfast.desktop $out/share/applications/zapfast.desktop
    install -Dm644 packaging/icons/zapfast.svg $out/share/icons/hicolor/scalable/apps/zapfast.svg

    wrapProgram $out/bin/.zapfast-unwrapped \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs}

    cat << WRAPPER > $out/bin/zapfast
#!/usr/bin/env bash
exec ${raise-or-run}/bin/raise-or-run zapfast "$out/bin/.zapfast-unwrapped" "\$@"
WRAPPER
    chmod +x $out/bin/zapfast

    runHook postInstall
  '';

  meta = {
    description = "Fast native WhatsApp client";
    homepage = "https://zapfast.rocks";
    license = with lib.licenses; [ mit gpl2Only ];
    mainProgram = "zapfast";
    platforms = [ "x86_64-linux" ];
  };
}
