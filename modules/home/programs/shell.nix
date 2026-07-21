{ pkgs, ... }:
{
  home.file.".inputrc".source = ../../../config/shell/inputrc;

  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      historyControl = [
        "erasedups"
        "ignoredups"
        "ignorespace"
      ];
      historySize = 500;
      historyFileSize = 10000;
      shellAliases = {
        edit = "hx";
        shx = "sudo hx";
        zj = "zellij";
        cat = "bat --no-pager";
        ls = "eza --icons=always";
        ll = "eza -alF --icons=always";
        la = "eza -a --icons=always";
        tree = "eza --tree --icons=always";
        rm = "rm -iv";
        cp = "cp -i";
        mv = "mv -i";
        open = "xdg-open";
      };
      initExtra = ''
        shopt -s histappend checkwinsize
        PROMPT_COMMAND='history -a'
        export LS_COLORS="$LS_COLORS:ow=01;34:tw=01;34:"
        export start_dir="/media/crim/productivity/Programming"
        [ -d "$start_dir" ] || export start_dir="$HOME"
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$PATH"

        # Match completion syntax to the Nix-managed Jujutsu version.
        source ${pkgs.jujutsu}/share/bash-completion/completions/jj.bash
      '';
    };

    bat = {
      enable = true;
      config.theme = "ansi";
    };
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };
    yazi = {
      enable = true;
      enableBashIntegration = true;
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
    };
    btop.enable = true;
    fastfetch.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  xdg.configFile = {
    "starship.toml".source = ../../../config/terminal/starship.toml;
    "btop/btop.conf".source = ../../../config/btop/btop.conf;
    "fastfetch/config.jsonc".source = ../../../config/fastfetch/config.jsonc;
  };
}
