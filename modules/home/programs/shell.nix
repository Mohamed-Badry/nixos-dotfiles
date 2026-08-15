{ config, pkgs, lib, ... }:
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
        "cd.." = "cd ..";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        bd = "cd \"$OLDPWD\"";
      };
      initExtra = ''
        shopt -s histappend checkwinsize
        PROMPT_COMMAND='history -a'
        export LS_COLORS="$LS_COLORS:ow=01;34:tw=01;34:"
        export INPUTRC="$HOME/.inputrc"

        start_dir="/media/${config.home.username}/productivity/Programming"
        [ -d "$start_dir" ] || start_dir="$HOME"
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$HOME/.local/bin:$PATH"

        # Match completion syntax to the Nix-managed Jujutsu version.
        source ${pkgs.jujutsu}/share/bash-completion/completions/jj.bash

        # Enhanced 'cd' that lists files after entering
        cd () {
            if [ -n "$1" ]; then
                builtin cd "$@" && eza --icons=always
            else
                builtin cd "$start_dir" && eza --icons=always
            fi
        }

        # Detach app from terminal session
        detach() {
            setsid -f "$@" > /dev/null 2>&1
        }

        # Quick Copy/Move/Mkdir & Go
        cpg () {
            if [ -d "$2" ];then
                cp "$1" "$2" && cd "$2"
            else
                cp "$1" "$2"
            fi
        }
        mvg () {
            if [ -d "$2" ];then
                mv "$1" "$2" && cd "$2"
            else
                mv "$1" "$2"
            fi
        }
        mkdirg () {
            mkdir -p "$1"
            cd "$1"
        }

        # Go up N directories
        up () {
            local d=""
            limit=$1
            for ((i=1 ; i <= limit ; i++))
                do
                    d=$d/..
                done
            d=$(echo "$d" | sed 's/^\///')
            if [ -z "$d" ]; then
                d=..
            fi
            cd "$d"
        }
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
      silent = true;
      nix-direnv.enable = true;
      config = {
        global = {
          hide_env_diff = true;
        };
      };
    };
  };

  home.activation.setupStarshipConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/starship.toml" ] || [ -L "$HOME/.config/starship.toml" ]; then
      rm -f "$HOME/.config/starship.toml"
      cp -f ${../../../config/terminal/starship.toml} "$HOME/.config/starship.toml"
      chmod 644 "$HOME/.config/starship.toml"
    fi
  '';

  xdg.configFile = {
    "btop/btop.conf".source = ../../../config/btop/btop.conf;
    "fastfetch/config.jsonc".source = ../../../config/fastfetch/config.jsonc;
  };
}
