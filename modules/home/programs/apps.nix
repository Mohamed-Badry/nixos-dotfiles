{
  lib,
  pkgs,
  inputs,
  username,
  fullName ? username,
  email ? null,
  ...
}:
let
  vcsUser = {
    name = fullName;
  }
  // lib.optionalAttrs (email != null) {
    inherit email;
  };
  launch-zen-vesktop = pkgs.writeShellApplication {
    name = "launch-zen-vesktop";
    runtimeInputs = [ pkgs.niri ];
    text = ''
      # Spawn Zen
      zen &

      # Wait for the window to appear
      sleep 2

      # The biggest Mod+R cycle is 2/3 (66.7%). Mod++ (+10%) 3 times is +30%.
      # 66.7% + 30% = 96.7%
      niri msg action set-column-width "96.7%"

      # Spawn Vesktop on the right side
      vesktop &
      sleep 2
      niri msg action set-column-width "96.7%"
    '';
  };
in
{
  home.packages = [
    launch-zen-vesktop
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.cava
    pkgs.pcmanfm-qt
    pkgs.qt6.qtsvg
    pkgs.qt6.qtimageformats
    pkgs.nomacs
    pkgs.sioyek
    pkgs.qt6Packages.qt6ct
    pkgs.libsForQt5.qt5ct
    pkgs.kdePackages.breeze
    pkgs.rose-pine-kvantum
    pkgs.kdePackages.qtstyleplugin-kvantum
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.grim
    pkgs.slurp
    pkgs.satty
    pkgs.vesktop
    (pkgs.symlinkJoin {
      name = "mailspring";
      paths = [ pkgs.mailspring ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/mailspring \
          --add-flags "--password-store=gnome-libsecret"

        rm -f $out/share/applications/Mailspring.desktop
        substitute ${pkgs.mailspring}/share/applications/Mailspring.desktop $out/share/applications/Mailspring.desktop \
          --replace-fail "${pkgs.mailspring}/bin/mailspring" "$out/bin/mailspring"
      '';
    })
    pkgs.seahorse
    pkgs.libsecret
    pkgs.pavucontrol
    pkgs.dua
    pkgs.skim
    pkgs.just
    pkgs.taplo
    pkgs.typst
    pkgs.tinymist
    pkgs.oxipng
    pkgs.bottom
    pkgs.sem
    pkgs.tealdeer
    pkgs.transmission_4-qt
    pkgs.zip
    pkgs.unzip
    pkgs.unrar
    pkgs.p7zip
    pkgs.unar
    pkgs.gnutar
    pkgs.xz
    pkgs.gzip
    pkgs.bzip2
    pkgs.zstd
  ];

  home.activation.installMailspringTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/Mailspring/packages/Catppuccin-Mocha/"
    cp -rf ${
      pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "mailspring";
        rev = "5c4e860812950759b1f1bf144871082844cd";
        sha256 = "1wh6msrpi97gxr3wf27sl9zbmj141z4p6avfcymw47mfd21630hn";
      }
    }/src/Catppuccin-Mocha/* "$HOME/.config/Mailspring/packages/Catppuccin-Mocha/"
    chmod -R u+w "$HOME/.config/Mailspring/packages/Catppuccin-Mocha"
  '';

  programs = {
    obs-studio.enable = true;
    git = {
      enable = true;
      settings = {
        user = vcsUser;
        init.defaultBranch = "main";
        core.editor = "hx";
        pull.rebase = true;
      };
    };
    jujutsu = {
      enable = true;
      settings = {
        user = vcsUser;
        ui = {
          default-command = "log";
          editor = "hx";
        };
      };
    };
    vscode = {
      enable = true;
      profiles.default.extensions = [ pkgs.vscode-extensions.mvllow.rose-pine ];
    };
    fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "JetBrainsMono Nerd Font:size=12";
          fields = "name,generic,comment,categories,filename";
          terminal = "${pkgs.wezterm}/bin/wezterm";
          prompt = "❯ ";
          width = 45;
          lines = 15;
          horizontal-pad = 20;
          vertical-pad = 15;
          inner-pad = 8;
        };
        colors = {
          background = "191724f2";
          text = "e0def4ff";
          match = "eb6f92ff";
          selection = "2a2837ff";
          selection-text = "e0def4ff";
          selection-match = "f6c177ff";
          border = "c4a7e7ff";
        };
        border = {
          width = 2;
          radius = 8;
        };
      };
    };
  };

  xdg = {
    desktopEntries = {
      mailspring = {
        name = "Mailspring";
        genericName = "Mail Client";
        exec = "mailspring --password-store=gnome-libsecret %U";
        terminal = false;
        categories = [
          "Network"
          "Email"
        ];
        icon = "mailspring";
      };

      helix = {
        name = "Helix";
        genericName = "Text Editor";
        exec = "${pkgs.wezterm}/bin/wezterm start -- hx %F";
        terminal = false;
        categories = [
          "Utility"
          "TextEditor"
        ];
        icon = "helix";
      };
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm-qt.desktop";
        "text/plain" = "helix.desktop";
        "text/markdown" = "helix.desktop";
        "application/json" = "helix.desktop";
        "text/x-shellscript" = "helix.desktop";
        "text/x-python" = "helix.desktop";
        "text/x-rust" = "helix.desktop";
        "image/jpeg" = "org.nomacs.ImageLounge.desktop";
        "image/png" = "org.nomacs.ImageLounge.desktop";
        "image/webp" = "org.nomacs.ImageLounge.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "text/html" = "zen.desktop";
        "x-scheme-handler/discord" = "vesktop.desktop";
        "x-scheme-handler/mailto" = "Mailspring.desktop";
      };
    };

    configFile = {
      "Code/User/settings.json".source = ../../../config/vscode/settings.json;
      "Code/User/keybindings.json".source = ../../../config/vscode/keybindings.json;
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
