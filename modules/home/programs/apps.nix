{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    # browsers & chat
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.myPkgs.launch-zen-vesktop
    pkgs.myPkgs.vesktop-wrapped
    pkgs.myPkgs.zapfast
    pkgs.myPkgs.mailspring-wrapped

    # files & readers
    pkgs.nomacs
    pkgs.sioyek
    pkgs.readest
    pkgs.transmission_4-qt

    # screenshots & media
    inputs.metrolist.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.grim
    pkgs.slurp
    pkgs.satty
    pkgs.cava
    pkgs.pwvucontrol
    pkgs.ffmpeg
    pkgs.oxipng

    # dev tools
    pkgs.gcc
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-script
    pkgs.uv
    (pkgs.python3.withPackages (ps: [ ps.mutagen ]))
    pkgs.just
    pkgs.taplo
    pkgs.typst
    pkgs.tinymist

    # cli utilities
    pkgs.bottom
    pkgs.dua
    pkgs.skim
    pkgs.sem
    pkgs.tealdeer

    # compression
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

    # qt & keyring
    pkgs.qt6.qtsvg
    pkgs.qt6.qtimageformats
    pkgs.qt6Packages.qt6ct
    pkgs.libsForQt5.qt5ct
    pkgs.kdePackages.breeze
    pkgs.rose-pine-kvantum
    pkgs.kdePackages.qtstyleplugin-kvantum
    pkgs.libsForQt5.qtstyleplugin-kvantum
    pkgs.seahorse
    pkgs.libsecret
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

  xdg.configFile."satty/config.toml".text = ''
    [general]
    output-filename = "~/Pictures/Screenshots/%Y-%m/satty-%Y%m%d-%H%M%S.png"
  '';

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
