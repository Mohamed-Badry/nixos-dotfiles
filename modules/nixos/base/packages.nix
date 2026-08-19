{ pkgs, inputs, ... }:
let
  perfmode = pkgs.stdenv.mkDerivation rec {
    pname = "perfmode";
    version = "2026-02-25";

    src = pkgs.fetchzip {
      url = "https://codeberg.org/icebarf/perfmode/archive/96b65f3511b6ff51f6b5a354c074f09968d99826.tar.gz";
      hash = "sha256-hpCThmBq+p0FdfyDJSwMXv6s6IJWwVMtUJsSnRvGef0=";
    };

    makeFlags = [ "PREFIX=$(out)" ];
  };
in
{
  environment.systemPackages = [
    pkgs.vim
    pkgs.wget
    pkgs.curl
    pkgs.git
    pkgs.fd
    pkgs.ripgrep
    pkgs.wl-clipboard
    pkgs.libnotify
    pkgs.heroic
    pkgs.cloudflare-warp
    pkgs.opencode
    perfmode
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
  ];

  environment.pathsToLink = [ "/share/bash-completion" ];
}
