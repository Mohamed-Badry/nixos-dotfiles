{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  configContent =
    builtins.replaceStrings
      [
        "@HOME@"
        "@ASUS_AURA_SYNC@"
      ]
      [
        config.home.homeDirectory
        "${pkgs.myPkgs.asus-aura-sync}/bin/asus-aura-sync"
      ]
      (builtins.readFile ../../../config/noctalia/config.toml);
  noctaliaPkg =
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace src/config/config_types.cpp \
            --replace-fail 'return std::clamp(backgroundOpacity + 0.08F, 0.82F, 0.92F);' \
                           'return std::clamp(backgroundOpacity * 0.55F, 0.35F, 0.48F);' \
            --replace-fail 'return std::clamp(backgroundOpacity + 0.10F, 0.62F, 0.75F);' \
                           'return std::clamp(backgroundOpacity * 0.40F, 0.22F, 0.34F);' \
            --replace-fail 'return 0.80F;' \
                           'return 0.69F;'

          for f in lib/ui/controls/button.h lib/ui/controls/select.h lib/ui/controls/segmented.h lib/ui/controls/input.h lib/ui/controls/stepper.h; do
            substituteInPlace "$f" \
              --replace-fail 'float m_surfaceOpacity = 1.0F;' \
                             'float m_surfaceOpacity = 0.42F;'
          done

          for f in lib/ui/controls/flex.h lib/ui/controls/box.h lib/ui/controls/scroll_view.h; do
            substituteInPlace "$f" \
              --replace-fail 'float fillOpacity = 1.0F' \
                             'float fillOpacity = 0.42F'
          done

          substituteInPlace lib/ui/controls/button.cpp \
            --replace-fail 'm_palette.normal.bg.alpha *= m_surfaceOpacity;' \
                           'const float effOpacity = (m_variant == ButtonVariant::Primary || m_variant == ButtonVariant::TabActive) ? std::clamp(m_surfaceOpacity + 0.36F, 0.76F, 0.85F) : m_surfaceOpacity; m_palette.normal.bg.alpha *= effOpacity;'

          substituteInPlace lib/ui/controls/input.cpp \
            --replace-fail 'focused ? resolved(ColorRole::Surface, m_surfaceOpacity) : resolved(m_surfaceRole, m_surfaceOpacity)' \
                           'resolved(m_surfaceRole, m_surfaceOpacity)'

          substituteInPlace src/shell/launcher/launcher_panel.cpp \
            --replace-fail 'm_row->setFill(colorSpecFromRole(ColorRole::Primary));' \
                           'm_row->setFill(colorSpecFromRole(ColorRole::Primary, 0.78F));' \
            --replace-fail 'm_col->setFill(colorSpecFromRole(ColorRole::Primary));' \
                           'm_col->setFill(colorSpecFromRole(ColorRole::Primary, 0.78F));'

          substituteInPlace src/shell/wallpaper/panel/wallpaper_tile.cpp \
            --replace-fail 'ColorSpec frameBg = colorSpecFromRole(ColorRole::SurfaceContainer);' \
                           'ColorSpec frameBg = colorSpecFromRole(ColorRole::SurfaceContainer, 0.42F);'

          substituteInPlace src/scripting/ui/ui_tree_reconciler.cpp \
            --replace-fail 'return colorSpecFromRole(*role, alpha);' \
                           'return colorSpecFromRole(*role, (*role == ColorRole::SurfaceContainer && base.size() == token->size()) ? 0.42F : alpha);'

          substituteInPlace src/shell/control_center/tabs/home_tab.cpp \
            --replace-fail 'button.setSurfaceOpacity(on ? 1.0F : fillOpacity);' \
                           'button.setSurfaceOpacity(on ? std::clamp(fillOpacity + 0.38F, 0.72F, 1.0F) : fillOpacity);' \
            --replace-fail '(void)opacity;' \
                           'const float s = contentScale(); if (m_userCard != nullptr) { applyHomeCardStyle(*m_userCard, s, opacity); } if (m_mediaCard != nullptr) { applyHomeCardStyle(*m_mediaCard, s, opacity); } if (m_dateTimeCard != nullptr) { applyHomeCardStyle(*m_dateTimeCard, s, opacity); m_dateTimeCard->setDirection(FlexDirection::Horizontal); m_dateTimeCard->setAlign(FlexAlign::Center); m_dateTimeCard->setJustify(FlexJustify::Center); m_dateTimeCard->setGap(Style::spaceLg * s); }'

          substituteInPlace src/shell/panel/panel_button_style.h \
            --replace-fail 'button.setVariant(ButtonVariant::Default);' \
                           'button.setVariant(ButtonVariant::Default); button.setSurfaceOpacity(0.42F);'
        '';
      });
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    package = noctaliaPkg;
    checkConfig = true;
    systemd.enable = true;
    settings = configContent;
  };

  home.packages = [
    pkgs.myPkgs.asus-aura-sync
    pkgs.pulseaudio
    pkgs.bluez
    pkgs.coreutils
  ];

  home.activation.seedNoctaliaConfigs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/gtk-3.0"
    if [ ! -f "$HOME/.config/gtk-3.0/noctalia.css" ]; then
      touch "$HOME/.config/gtk-3.0/noctalia.css"
    fi
    mkdir -p "$HOME/.config/sioyek"
    if [ ! -f "$HOME/.config/sioyek/prefs_user.config" ]; then
      touch "$HOME/.config/sioyek/prefs_user.config"
    fi
    mkdir -p "$HOME/.codex/themes"
    mkdir -p "$HOME/.config/zapfast"
  '';
}
