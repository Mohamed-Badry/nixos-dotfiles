{ pkgs, lib }:
let
  src = pkgs.fetchgit {
    url = "https://github.com/Darkkal44/qylock.git";
    rev = "db61a972b4b23728d9944a906e70029ca8a5899d";
    sparseCheckout = [
      "themes/sword"
      "quickshell-lockscreen"
    ];
    hash = "sha256-SDghYrgiDvHBOWwHRKPiy4TRemJZ+X9nhmaaew5OM90=";
  };

  swordVideo = pkgs.runCommand "sword-lockscreen-video.mp4" { } ''
    mkdir -p $out
    cp ${../assets/sddm/sword-4k.mp4} $out/bg.mp4
  '';

  backgroundVideoQml = ''
    import QtQuick
    import QtQuick.Window
    import QtMultimedia

    Item {
        readonly property real s: Screen.height / 768
        anchors.fill: parent
        MediaPlayer {
            id: mediaplayer
            source: "bg.mp4"
            autoPlay: true
            loops: MediaPlayer.Infinite
            videoOutput: videoOutput
        }
        VideoOutput {
            id: videoOutput
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop
        }
        Image {
            id: placeholder
            source: "bg.jpg"
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            opacity: (mediaplayer.playbackState === MediaPlayer.PlayingState && mediaplayer.position > 100) ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 400 } }
        }
    }
  '';

  gstreamerPlugins = with pkgs.gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gst-libav
  ];

  qmlPath = lib.makeSearchPathOutput "lib" "qt-6/qml" [
    pkgs.kdePackages.qt5compat
    pkgs.kdePackages.qtdeclarative
    pkgs.kdePackages.qtmultimedia
    pkgs.kdePackages.qtsvg
  ];

  qtPluginPath = lib.makeSearchPathOutput "lib" "qt-6/plugins" [
    pkgs.kdePackages.qtbase
    pkgs.kdePackages.qtdeclarative
    pkgs.kdePackages.qtmultimedia
    pkgs.kdePackages.qtsvg
  ];
in
rec {
  sddmTheme = pkgs.stdenvNoCC.mkDerivation {
    pname = "qylock-sddm-themes";
    version = "db61a972";
    inherit src;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -r themes/. $out/share/sddm/themes/
      rm -f $out/share/sddm/themes/sword/bg.mp4
      ln -s ${swordVideo}/bg.mp4 $out/share/sddm/themes/sword/bg.mp4
      cp ${../assets/sddm/bg.jpg} $out/share/sddm/themes/sword/bg.jpg
      cat > $out/share/sddm/themes/sword/BackgroundVideo.qml <<'QML'
      ${backgroundVideoQml}
      QML
    '';
  };

  lock = pkgs.stdenvNoCC.mkDerivation {
    pname = "qylock-lock";
    version = "db61a972";
    inherit src;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;
    installPhase = ''
            mkdir -p $out/share/qylock $out/bin
            cp -r quickshell-lockscreen/. $out/share/qylock/
            cp -r themes $out/share/qylock/themes
            rm -f $out/share/qylock/themes/sword/bg.mp4
            ln -s ${swordVideo}/bg.mp4 $out/share/qylock/themes/sword/bg.mp4
            cp ${../assets/sddm/bg.jpg} $out/share/qylock/themes/sword/bg.jpg
            cat > $out/share/qylock/themes/sword/BackgroundVideo.qml <<'QML'
            ${backgroundVideoQml}
            QML

            makeWrapper $out/share/qylock/lock.sh $out/bin/qylock-lock \
              --set QS_THEME sword \
              --set QYLOCK_THEMES_ROOT $out/share/qylock/themes \
              --suffix QML2_IMPORT_PATH : ${qmlPath} \
              --suffix QML_IMPORT_PATH : ${qmlPath} \
              --suffix QT_PLUGIN_PATH : ${qtPluginPath} \
              --set QT_MEDIA_BACKEND gstreamer \
              --suffix GST_PLUGIN_SYSTEM_PATH_1_0 : ${
                lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstreamerPlugins
              } \
              --prefix PATH : ${
                lib.makeBinPath [
                  pkgs.quickshell
                  pkgs.psmisc
                  pkgs.systemd
                  pkgs.coreutils
                ]
              }

            substituteInPlace $out/share/qylock/lock.sh \
              --replace-fail 'export QS_THEME="nier-automata"' 'export QS_THEME="''${QS_THEME:-sword}"' \
              --replace-fail 'export QS_THEME_PATH="$DIR/../themes/$QS_THEME"' 'export QS_THEME_PATH="$QYLOCK_THEMES_ROOT/$QS_THEME"' \
              --replace-fail 'export QS_THEME_PATH="$DIR/themes_link/$QS_THEME"' 'export QS_THEME_PATH="$QYLOCK_THEMES_ROOT/$QS_THEME"'
    '';
  };
}
