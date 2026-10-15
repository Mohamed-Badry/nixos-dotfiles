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
    pkgs.myPkgs.perfmode
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.codex
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.rtk
  ];

  environment.pathsToLink = [ "/share/bash-completion" ];
}
