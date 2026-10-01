{
  config,
  pkgs,
  lib,
  ...
}:
{
  home.file.".inputrc".source = ../../../config/shell/inputrc;

  programs = {
    fish = {
      enable = true;
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
        bd = "cd \"$OLDPWD\"";
        p = "ps aux | rg";
      };
      interactiveShellInit = ''
        set -gx LS_COLORS "$LS_COLORS:ow=01;34:tw=01;34:"
        set -gx MPD_HOST "$HOME/.config/mpd/socket"
        set -gx MPD_PORT ""

        set start_dir "/media/${config.home.username}/productivity/Programming"
        if not test -d "$start_dir"
            set start_dir "$HOME"
        end

        set -gx BUN_INSTALL "$HOME/.bun"
        fish_add_path "$BUN_INSTALL/bin" "$HOME/.local/bin"

        # The "Fish Way" to run eza after ANY directory change (cd, z, popd, multicd, up)
        function on_pwd_change --on-variable PWD
            if status is-interactive
                eza --icons=always
            end
        end

        # Multicd abbreviation (e.g. typing '...' expands to 'cd ../..')
        function multicd
            echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
        end
        abbr --add dotdot --regex '^\.\.+$' --function multicd

        # Alt+S to toggle sudo
        function __fish_toggle_sudo
            set -l cmd (commandline)
            if string match -q "sudo *" $cmd
                commandline (string replace -r "^sudo " "" $cmd)
            else
                commandline "sudo $cmd"
            end
        end
        bind \es __fish_toggle_sudo

        # Disable the default Fish greeting
        set -g fish_greeting ""
      '';
      functions = {
        cd = ''
          if count $argv > /dev/null
              builtin cd $argv
          else
              builtin cd $start_dir
          end
        '';
        detach = ''
          setsid -f $argv > /dev/null 2>&1
        '';
        cpg = ''
          if test -d "$argv[2]"
              cp $argv[1] $argv[2]; and builtin cd $argv[2]
          else
              cp $argv[1] $argv[2]
          end
        '';
        mvg = ''
          if test -d "$argv[2]"
              mv $argv[1] $argv[2]; and builtin cd $argv[2]
          else
              mv $argv[1] $argv[2]
          end
        '';
        mkdirg = ''
          mkdir -p $argv[1]; and builtin cd $argv[1]
        '';
        up = ''
          set -l d ""
          set -l limit $argv[1]
          if test -z "$limit"
              set limit 1
          end
          for i in (seq 1 $limit)
              set d $d/..
          end
          set d (string replace -r '^/' ''' $d)
          if test -z "$d"
              set d ..
          end
          builtin cd $d
        '';
      };
    };

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
      enableFishIntegration = true;
    };
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
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
    "fastfetch/config.jsonc".source = ../../../config/fastfetch/config.jsonc;
  };
}
