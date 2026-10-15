{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    pkgs.myPkgs.launch-zen-vesktop
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
    pkgs.myPkgs.mailspring-wrapped
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
    pkgs.ffmpeg
    (pkgs.python3.withPackages (ps: [ ps.mutagen ]))
  ];

  programs = {
    yt-dlp = {
      enable = true;
      package = pkgs.myPkgs.yt-dlp-wrapped;
      settings = {
        extractor-args = "youtube:player_client=android,web";
      };
    };

    obs-studio.enable = true;

    vscode = {
      enable = true;
      profiles.default.extensions = [ pkgs.vscode-extensions.mvllow.rose-pine ];
    };
  };

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
}
