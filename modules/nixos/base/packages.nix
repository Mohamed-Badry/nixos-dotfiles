{ pkgs, inputs, ... }:
{
  programs = {
    nix-index-database.comma.enable = true;
    nix-index = {
      enableBashIntegration = false;
      enableFishIntegration = false;
      enableZshIntegration = false;
    };
    fish.enable = true;
  };

  environment.systemPackages = [
    # core cli
    pkgs.curl
    pkgs.wget
    pkgs.git
    pkgs.vim
    pkgs.fd
    pkgs.ripgrep
    pkgs.wl-clipboard
    pkgs.libnotify
    pkgs.android-tools

    # gaming & network
    pkgs.heroic
    pkgs.cloudflare-warp
    pkgs.myPkgs.perfmode

    # agent clis
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.rtk
  ];

  environment.pathsToLink = [ "/share/bash-completion" ];
}
