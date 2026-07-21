{ pkgs, inputs, ... }:
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
    inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.google-antigravity-cli
  ];

  environment.pathsToLink = [ "/share/bash-completion" ];
}
